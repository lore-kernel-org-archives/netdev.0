From: Devesh Agrawal <devesh.agrawal@gmail.com>
Subject: Re: How to route a skb to a particular oif, when the fib_lookup suggests another one.
Date: Sun, 27 Mar 2005 08:04:18 +0530
Message-ID: <db01ab35050326183462cb92fd@mail.gmail.com>
References: <db01ab3505032313427fcd144f@mail.gmail.com>
	 <db01ab3505032313517830af81@mail.gmail.com>
	 <db01ab3505032521504ac85fcc@mail.gmail.com>
	 <537f59d105032609144e0ac813@mail.gmail.com>
Reply-To: Devesh Agrawal <devesh.agrawal@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Vinay Reddy <vinayvinay@gmail.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
In-Reply-To: <537f59d105032609144e0ac813@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
I don't think that will solve the problem cos: 
rt_intern_hash called in the finall stages of make_route in
ip_route_output_slow tries to arp bind a the next hop. If you give a
different ip address, then it may not either ever know of the mac
address of this ghost ip or worse may get a wrong mac address and go
to a wrong next hop.
What happens if we set the tos flag to have RTO_ONLINK set, so that
the scope is RT_SCOPE_LINK, with oif set to the desired output
interface, can I then force the skb thru that ouput interface?
I would be really grateful if some one helps me out with this.
Eagerly awaiting your replies.
Regards,
Devesh Agrawal

On Sat, 26 Mar 2005 22:44:53 +0530, Vinay Reddy <vinayvinay@gmail.com> wrote:
> Hi,
> Say packets for 10.6.0.0 is always routed through wlan0, and you want
> packets for 10.7.0.0 to be routed through one of eth0 or wlan0
> depending on their IPs(required for mobile IP). Also assume that the
> default routing for a 10.7.0.0 network IP is done through eth0. Now
> you want to route a packet destined for 10.7.0.2 through wlan0. You
> can just call ip_route_output_key for 10.6.0.1. This way the packet
> will surely go through wlan0.
> Am I missing anything??
> 
> Cheers,
> Vinay
> 
> On Sat, 26 Mar 2005 11:20:22 +0530, Devesh Agrawal
> <devesh.agrawal@gmail.com> wrote:
> > Hi,
> > I have to route a packet thru a particular output interface, however
> > my routing tables have two routes, that match it : one to eth0 and one
> > to wlan0, with the eth0 being chosen as it is more specific.  I am
> > using ip_route_output_key, with fl->oif = index of device I want this
> > packet to go (=wlan0).
> > However, in the ip_route_output_slow I found that even when oif is not
> > 0, you get a valid dev_out, however when the fib_lookup succeeds, you
> > merely free this old dev_out, and assign dev_out to the res.dev (ie
> > the one found out by the fib_lookup),
> > So this means that even if I specify the oif, the packet will still
> > get routed to eth0.
> > Am I correct, or is there something I am missing. Also I am setting
> > tos bit RTO_ONLINK .
> > Please help me. I am quite perplexed by this.
> > Sincerely,
> > --
> > Devesh Agrawal
> > -
> > To unsubscribe from this list: send the line "unsubscribe linux-net" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> 
> 
> --
> Vinay Kumar Reddy B
> 238, Mandakini Hostel,
> IIT Madras,
> Chennai  - 600036
> 


-- 
Devesh Agrawal
4th year Dual Degree.
Dept of CSE 
Indian Institute of Technology , Madras
Room No . 309 , Alakananda Hostel 
Chennai 600036 ,India
Ph : +91 9382102431
