From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: 2.6.33 dies on modprobe
Date: Wed, 3 Mar 2010 17:18:45 +0800
Message-ID: <2375c9f91003030118x144a47d3n1dd5a08e88c144d3@mail.gmail.com>
References: <20100228221257.GA8858@invalid>
	 <2375c9f91002282022n29e83858jd8cadbb2e664b436@mail.gmail.com>
	 <20100301090708.GF17929@forwiss.uni-passau.de>
	 <2375c9f91003030058h7456b5e1odc8ca958f5af2c0d@mail.gmail.com>
	 <2375c9f91003030108h43973d0cw713d1004dd912389@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016363b82f0254d150480e1f8c6
Cc: Greg Kroah-Hartman <gregkh@suse.de>
To: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>,
	linux-kernel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2375c9f91003030108h43973d0cw713d1004dd912389@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--0016363b82f0254d150480e1f8c6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 3, 2010 at 5:08 PM, Am=C3=A9rico Wang <xiyou.wangcong@gmail.com=
> wrote:
> On Wed, Mar 3, 2010 at 4:58 PM, Am=C3=A9rico Wang <xiyou.wangcong@gmail.c=
om> wrote:
>> On Mon, Mar 1, 2010 at 5:07 PM, M G Berberich
>> <berberic@fmi.uni-passau.de> wrote:
>>> Hello,
>>>
>>> Am Montag, den 01. M=C3=A4rz schrieb Am=C3=A9rico Wang:
>>>> On Mon, Mar 1, 2010 at 6:12 AM, M G Berberich
>>>> <berberic@fmi.uni-passau.de> wrote:
>>>
>>>> > I tried to build a 2.6.33 kernel but on boot it dies on modprobe
>>>> > (kernel-Oops). This might be the result of faulty config, but I'm
>>>> > totaly clueless what's the fault.
>>>> >
>>>> > The kernel starts up fine and mounts the root-filesystem, but then
>>>> > dies on the first modprobe executed. I can boot it with init=3D/bin/=
bash
>>>> > and get a working bash (until I do modprobe on any module).
>>>> >
>>>> > System is a Gigabyte M55S-S3 rev 2.0 (nForce 550) with an AMD Athlon=
64
>>>> > X2 5000+ and amd64-kernel architecture. kernel-sources are from
>>>> > kernel.org.
>>>
>>>> It seems something is wrong with forcedeth code or PCI code.
>>>> Adding some Cc's.
>>>
>>> I don't think it's forcedeth. forcedeth just happens to be the first
>>> module that get's loaded in startup. It crashes with any other module
>>> too (I tried ohci_hcd).
>>>
>>
>> Ok, below is my patch, I am not sure it could fix the BUG for you,
>> but it could fix the WARNING. But perhaps they are related.
>>
>> Please give it a try.
>>
>
> Oops! Ignore the patch, it should not be correct, I will send a
> correct version soon.
> Sorry.
>

Here we go:

--------------------->

It looks really odd that we do class_put() in non-failure path of
__class_register(). This seems wrong.

To fix this, just remove class_get() in __class_register(), we don't need
to call class_get() to get ref of cls->p->class_subsys, because
kset_register() has already done this for us.

Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>

--0016363b82f0254d150480e1f8c6
Content-Type: text/plain; charset=US-ASCII; name="drivers-base-class_c-move-class_put.diff"
Content-Disposition: attachment;
	filename="drivers-base-class_c-move-class_put.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g6bx4d9e0

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvYmFzZS9jbGFzcy5jIGIvZHJpdmVycy9iYXNlL2NsYXNzLmMK
aW5kZXggNmUyYzNiMC4uNjk1ZDYyNCAxMDA2NDQKLS0tIGEvZHJpdmVycy9iYXNlL2NsYXNzLmMK
KysrIGIvZHJpdmVycy9iYXNlL2NsYXNzLmMKQEAgLTE5MSw4ICsxOTEsNyBAQCBpbnQgX19jbGFz
c19yZWdpc3RlcihzdHJ1Y3QgY2xhc3MgKmNscywgc3RydWN0IGxvY2tfY2xhc3Nfa2V5ICprZXkp
CiAJCWtmcmVlKGNwKTsKIAkJcmV0dXJuIGVycm9yOwogCX0KLQllcnJvciA9IGFkZF9jbGFzc19h
dHRycyhjbGFzc19nZXQoY2xzKSk7Ci0JY2xhc3NfcHV0KGNscyk7CisJZXJyb3IgPSBhZGRfY2xh
c3NfYXR0cnMoY2xzKTsKIAlyZXR1cm4gZXJyb3I7CiB9CiBFWFBPUlRfU1lNQk9MX0dQTChfX2Ns
YXNzX3JlZ2lzdGVyKTsK
--0016363b82f0254d150480e1f8c6--
