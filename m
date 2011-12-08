From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipip, sit: copy parms.name after register_netdevice
Date: Wed, 7 Dec 2011 20:16:10 -0800
Message-ID: <20111207201610.7cc9714a@nehalam.linuxnetplumber.net>
References: <CAM7b5hzt8D6hn3=XEcm9E3_BwJxj-YABpkufCpuhjiPLDxCsMQ@mail.gmail.com>
	<20111206173220.GA28763@kroah.com>
	<CAM7b5hyXkRTUwnE-NwXEff-34WjRfMSBDf2itMVhdJGi4XoA=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Josh Boyer <jwboyer@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ted Feng <artisdom@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM7b5hyXkRTUwnE-NwXEff-34WjRfMSBDf2itMVhdJGi4XoA=g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 8 Dec 2011 11:35:15 +0800
Ted Feng <artisdom@gmail.com> wrote:

> From: Ted Feng <artisdom@gmail.com>
> Same fix as 731abb9cb2 for ipip and sit tunnel.
> Commit 1c5cae815d removed an explicit call to dev_alloc_name in
> ipip_tunnel_locate and ipip6_tunnel_locate, because register_netdevice
> will now create a valid name. However the tunnel keeps a copy of the
> name in the private parms structure.
> 
> This shows up if you do a simple tunnel add, followed by a tunnel show:
> 

Ok, but keeping a private copy is not a good idea, since tunnel
can be renamed.
  ip li set dev tun0 name tunnel-of-love
