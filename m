From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Mark SIOCSIFNAME as compatible ioctl
Date: Fri, 9 Jan 2004 16:56:27 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109165627.2e0845af.ak@suse.de>
References: <20040108070413.GA31778@averell>
	<20040109020456.045b447e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040109020456.045b447e.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 9 Jan 2004 02:04:56 -0800
"David S. Miller" <davem@redhat.com> wrote:

> On Thu, 8 Jan 2004 08:04:13 +0100
> Andi Kleen <ak@muc.de> wrote:
> 
> > Mark SIOCSIFNAME as an ioctl that doesn't need 32bit conversion.
> > 
> > Fixes nameif as 32bit executable.
> 
> How can we mark it compatible?  It needs the stuff dev_ifname32() in
> fs/compat_ioctl.c does for SIOCGIFNAME doesn't it?

It takes two strings. This should be compatible:

struct ifreq 
{
        union
        {
                char    ifrn_name[IFNAMSIZ];            /* if name, e.g. "en0" */
/
        } ifr_ifrn;
	 union {     
		...
                char    ifru_newname[IFNAMSIZ]; 
		...
        } ifr_ifru;
}; 

-Andi

P.S.: Maybe it would be time update the "en0" comment in if.h too ;-) I bet that comes from
VAX/BSD.
