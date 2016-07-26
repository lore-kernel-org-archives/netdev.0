From: Jesper Dangaard Brouer via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: XDP seeking input from NIC hardware vendors
Date: Tue, 26 Jul 2016 20:42:03 +0200
Message-ID: <20160726204203.452e988c@redhat.com>
References: <20160707124245.6d95635a@redhat.com> <5785413D.4050901@gmail.com>
	<20160712223231.202cd122@redhat.com> <1619174.FzfZHYFiS5@xps13>
	<CALx6S35XjCsG5EmiYBpbGk9NckQbe4VbNSGLqV7h+d16PgNGKg@mail.gmail.com>
	<5797A381.90406@gmail.com>
Reply-To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>, adrien.mazarguil-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
	Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	Tom Herbert via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	"Fastabend, John R" <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Rana Shahout <ranas-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Ari Saha <as754m-60p5jsuXm+c@public.gmane.org>
To: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <5797A381.90406-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 26 Jul 2016 10:53:05 -0700
John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On 16-07-26 09:08 AM, Tom Herbert wrote:
> > On Tue, Jul 26, 2016 at 6:31 AM, Thomas Monjalon
> > <thomas.monjalon-pdR9zngts4EAvxtiuMwx3w@public.gmane.org> wrote:  
> >> Hi,
> >>
> >> About RX filtering, there is an ongoing effort in DPDK to write an API
> >> which could leverage most of the hardware capabilities of any NICs:
> >>         https://rawgit.com/6WIND/rte_flow/master/rte_flow.html
> >>         http://thread.gmane.org/gmane.comp.networking.dpdk.devel/43352
> >> I understand that XDP does not target to support every hardware features,
> >> though it may be an interesting approach to check.
> >>  
> > Thomas,
> > 
> > A major goal of XDP is to leverage and in fact encourage innovation in
> > hardware features. But, we are asking that vendors design the APIs
> > with the community in mind. For instance, if XDP supports crypto
> > offload it should have one API that different companies, we don't want
> > every vendor coming up with their own.  
> 
> The work in those threads is to create a single API for users of DPDK
> to interact with their hardware. The equivalent interface in Linux
> kernel is ntuple filters from ethtool the effort here is to make a
> usable interface to manage this from an application and also expose
> all the hardware features. Ethtool does a fairly poor job on both
> fronts IMO.

Yes, the ethtool + ntuple approach is unfortunately not very easy to :-(


> If we evolve the mechanism to run per rx queue xdp programs this
> interface could easily be used to forward packets to specific rx
> queues and run targeted xdp programs.
> 
> Integrating this functionality into running XDP programs as ebpf code
> seems a bit challenging to me because there is no software equivalent.
> Once XDP ebpf program is running the pkt has already landed on the rx
> queue. To me the mechanism to bind XDP programs to rx queues and steer
> specific flows (e.g. match a flow label and forward to a queue) needs
> to be part of the runtime environment not part of the main ebpf program
> itself. 

I agree, based on the discussion in this thread. Will admit that my
initial idea of adding this filter to the eBPF/XDP program was not such
a good idea.

> The runtime environment could use the above linked API. I know
> we debated earlier including this in the ebpf program itself but that
> really doesn't seem feasible to me. Whether the steering is expresses
> as an ebpf program or an API like above seems like a reasonable
> discussion. Perhaps a section could be used to describe the per program
> filter for example which would be different from an API approach used
> in the proposal above or the JIT could translate it into the above
> API for devices without instruction based hardware.

It seems like someone actually put some though into this, in the link
you send... quite interesting, thanks:
 https://rawgit.com/6WIND/rte_flow/master/rte_flow.html

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
