From: Mike Waychison <mikew@google.com>
Subject: Re: [PATCH v2 1/3] virtio_net: Split receive buffer alloc/add
Date: Tue, 10 Jan 2012 17:42:24 -0800
Message-ID: <CAGTjWtApo4WgPjPsRxpjJBjLrcXHr=SdDq_ryuHDwRnZHvjrng@mail.gmail.com>
References: <20120110174052.4505.66514.stgit@mike2.sea.corp.google.com>
	<20120110174100.4505.8939.stgit@mike2.sea.corp.google.com>
	<8739bn6n66.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: earhart@google.com, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, digitaleric@google.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <8739bn6n66.fsf@rustcorp.com.au>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 10, 2012 at 5:30 PM, Rusty Russell <rusty@rustcorp.com.au> wrot=
e:
> On Tue, 10 Jan 2012 09:41:01 -0800, Mike Waychison <mikew@google.com> wro=
te:
>> In preparation for allocating receive buffers in the slow path without
>> disabling NAPI, split the allocation and addition of receive buffers
>> apart into two separate functions (per receive buffer type).
>>
>> While here, move the vi->num accounting into the add functions.
>>
>> Signed-off-by: Mike Waychison <mikew@google.com>
>
> Hi Mike...
>
> =A0 =A0 =A0 =A0This exposes a nasty ugliness in the way virtio_net works.=
 =A0We
> allocate an skbuff for the small packet case, and just allocate the
> pages for the large packet cases, and alloc the skbuff when we fill the
> pages.
>
> =A0 =A0 =A0 =A0I think all the allocators should return a populated skbuf=
f;
> this uses a bit more memory in theory, but should make the code simpler.
> As an added bonus, your life should get much simpler for these patches.
>
> I'll try to create such a patch tonight, but I'm busy finalizing my
> linux.conf.au presentation, so it might take longer :(
>

This seems reasonable for the "big" receive buffers, but I don't think
it makes a lot of sense for "mergeable" receive buffers as best I can
tell.  Hopefully making this work isn't too hard though :)
