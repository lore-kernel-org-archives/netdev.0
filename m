From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v2 1/3] virtio_net: Split receive buffer alloc/add
Date: Wed, 11 Jan 2012 12:00:25 +1030
Message-ID: <8739bn6n66.fsf@rustcorp.com.au>
References: <20120110174052.4505.66514.stgit@mike2.sea.corp.google.com>
	<20120110174100.4505.8939.stgit@mike2.sea.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, earhart@google.com, digitaleric@google.com,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Mike Waychison <mikew@google.com>, "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120110174100.4505.8939.stgit@mike2.sea.corp.google.com>
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

On Tue, 10 Jan 2012 09:41:01 -0800, Mike Waychison <mikew@google.com> wrote:
> In preparation for allocating receive buffers in the slow path without
> disabling NAPI, split the allocation and addition of receive buffers
> apart into two separate functions (per receive buffer type).
> 
> While here, move the vi->num accounting into the add functions.
> 
> Signed-off-by: Mike Waychison <mikew@google.com>

Hi Mike...

        This exposes a nasty ugliness in the way virtio_net works.  We
allocate an skbuff for the small packet case, and just allocate the
pages for the large packet cases, and alloc the skbuff when we fill the
pages.

        I think all the allocators should return a populated skbuff;
this uses a bit more memory in theory, but should make the code simpler.
As an added bonus, your life should get much simpler for these patches.

I'll try to create such a patch tonight, but I'm busy finalizing my
linux.conf.au presentation, so it might take longer :(

Thanks,
Rusty.
