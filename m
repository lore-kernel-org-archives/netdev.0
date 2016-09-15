From: Jesper Dangaard Brouer via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: XDP user interface confusions
Date: Thu, 15 Sep 2016 20:14:02 +0200
Message-ID: <20160915201402.15b65136@redhat.com>
Reply-To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	"iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org" <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Daniel Borkmann <borkmann-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
To: Brenden Blanco <bblanco-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
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

Hi Brenden,

I don't quite understand the semantics of the XDP userspace interface.

We allow XDP programs to be (unconditionally) exchanged by another
program, this avoids taking the link down+up and avoids reallocating
RX ring resources (which is great).

We have two XDP samples programs in samples/bpf/ xdp1 and xdp2.  Now I
want to first load xdp1 and then to avoid the linkdown I load xdp2,
and then afterwards remove/stop program xdp1.

This does NOT work, because (in samples/bpf/xdp1_user.c) when xdp1
exits it unconditionally removes the running XDP program (loaded by xdp2)
via set_link_xdp_fd(ifindex, -1).  The xdp2 user program is still
running, and is unaware of its xdp/bpf program have been unloaded.

I find this userspace interface confusing. What this your intention?
Perhaps you can explain what the intended semantics or specification is?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
