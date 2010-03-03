From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: 2.6.33 dies on modprobe
Date: Wed, 3 Mar 2010 16:58:12 +0800
Message-ID: <2375c9f91003030058h7456b5e1odc8ca958f5af2c0d@mail.gmail.com>
References: <20100228221257.GA8858@invalid>
	 <2375c9f91002282022n29e83858jd8cadbb2e664b436@mail.gmail.com>
	 <20100301090708.GF17929@forwiss.uni-passau.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=00163646db3e98cc940480e1ae90
Cc: Greg Kroah-Hartman <gregkh@suse.de>
To: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>,
	linux-kernel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100301090708.GF17929@forwiss.uni-passau.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--00163646db3e98cc940480e1ae90
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Mon, Mar 1, 2010 at 5:07 PM, M G Berberich
<berberic@fmi.uni-passau.de> wrote:
> Hello,
>
> Am Montag, den 01. M=C3=A4rz schrieb Am=C3=A9rico Wang:
>> On Mon, Mar 1, 2010 at 6:12 AM, M G Berberich
>> <berberic@fmi.uni-passau.de> wrote:
>
>> > I tried to build a 2.6.33 kernel but on boot it dies on modprobe
>> > (kernel-Oops). This might be the result of faulty config, but I'm
>> > totaly clueless what's the fault.
>> >
>> > The kernel starts up fine and mounts the root-filesystem, but then
>> > dies on the first modprobe executed. I can boot it with init=3D/bin/ba=
sh
>> > and get a working bash (until I do modprobe on any module).
>> >
>> > System is a Gigabyte M55S-S3 rev 2.0 (nForce 550) with an AMD Athlon64
>> > X2 5000+ and amd64-kernel architecture. kernel-sources are from
>> > kernel.org.
>
>> It seems something is wrong with forcedeth code or PCI code.
>> Adding some Cc's.
>
> I don't think it's forcedeth. forcedeth just happens to be the first
> module that get's loaded in startup. It crashes with any other module
> too (I tried ohci_hcd).
>

Ok, below is my patch, I am not sure it could fix the BUG for you,
but it could fix the WARNING. But perhaps they are related.

Please give it a try.

--------------------->

It looks really odd that we do class_put() in non-failure path of
class_register(), shouldn't it be in class_unregister()?
In fact we have this problem long time ago, since commit 7c71448b,
but a recent change (commit 18d19c964) uncovers this.

Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>

---

--00163646db3e98cc940480e1ae90
Content-Type: text/plain; charset=US-ASCII; name="drivers-base-class_c-move-class_put.diff"
Content-Disposition: attachment;
	filename="drivers-base-class_c-move-class_put.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g6bw86h60

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvYmFzZS9jbGFzcy5jIGIvZHJpdmVycy9iYXNlL2NsYXNzLmMK
aW5kZXggNmUyYzNiMC4uY2NmMzEyZCAxMDA2NDQKLS0tIGEvZHJpdmVycy9iYXNlL2NsYXNzLmMK
KysrIGIvZHJpdmVycy9iYXNlL2NsYXNzLmMKQEAgLTE5Miw3ICsxOTIsNiBAQCBpbnQgX19jbGFz
c19yZWdpc3RlcihzdHJ1Y3QgY2xhc3MgKmNscywgc3RydWN0IGxvY2tfY2xhc3Nfa2V5ICprZXkp
CiAJCXJldHVybiBlcnJvcjsKIAl9CiAJZXJyb3IgPSBhZGRfY2xhc3NfYXR0cnMoY2xhc3NfZ2V0
KGNscykpOwotCWNsYXNzX3B1dChjbHMpOwogCXJldHVybiBlcnJvcjsKIH0KIEVYUE9SVF9TWU1C
T0xfR1BMKF9fY2xhc3NfcmVnaXN0ZXIpOwpAQCAtMjAwLDYgKzE5OSw3IEBAIEVYUE9SVF9TWU1C
T0xfR1BMKF9fY2xhc3NfcmVnaXN0ZXIpOwogdm9pZCBjbGFzc191bnJlZ2lzdGVyKHN0cnVjdCBj
bGFzcyAqY2xzKQogewogCXByX2RlYnVnKCJkZXZpY2UgY2xhc3MgJyVzJzogdW5yZWdpc3Rlcmlu
Z1xuIiwgY2xzLT5uYW1lKTsKKwljbGFzc19wdXQoY2xzKTsKIAlyZW1vdmVfY2xhc3NfYXR0cnMo
Y2xzKTsKIAlrc2V0X3VucmVnaXN0ZXIoJmNscy0+cC0+Y2xhc3Nfc3Vic3lzKTsKIH0K
--00163646db3e98cc940480e1ae90--
