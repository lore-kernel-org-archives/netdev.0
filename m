From: "Kevin W. Rudd" <ruddk@us.ibm.com>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Wed, 10 Dec 2003 12:26:26 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312101218280.1354-100000@w-kevinr.svc.beaverton.ibm.com>
References: <20031210203433.3747b7fd.ak@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
        <chester.f.johnson@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20031210203433.3747b7fd.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I don't think it's practical to make these types of changes at the
router level.  Discounting not having the ability to change the IOS
behavior, it is quite probable that the router doing the marking is
beyond your control (e.g. at the ISP level).  The only network users
that would have to make this change would be those taking advantage
of a network using QoS marking (and a smaller MTU somewhere in the
path).  That's why the ideal short term solution would be to allow
the manipulation of this behavior via a sysctl option/variable,
but keep the default the same as it is now.

-Kevin

On Wed, 10 Dec 2003, Andi Kleen wrote:

> Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
> 
> On Wed, 10 Dec 2003 10:23:15 -0800 (PST)
> "Kevin W. Rudd" <ruddk@us.ibm.com> wrote:
> 
> > 
> > Thoughts?  Comments?
> 
> I don't think the network users will be very happy if you require changing all
> end hosts this way. How about the following hack? For DF=1 packets
> the ipid field is useless. When you rewrite the TOS to DSCP save
> the old TOS in the ipid field.  When you see an ICMP fragment required
> message with the right DSCP on the router restore the old TOS from the ipid 
> field.
> 
> One drawback is that there are a few VJ header compression servers that
> require changing ipid. But you can still handle these by not overwriting
> all bits of ipid so that it still changes (keep a few changing bits)
> 
> -Andi
> 

--
 Kevin W. Rudd
 Linux Change Team
 IBM Global Services
 1-800-426-7378,  T/L 775-4161
