From: Andi Kleen <ak@suse.de>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Wed, 10 Dec 2003 20:34:33 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210203433.3747b7fd.ak@suse.de>
References: <Pine.LNX.4.44.0312101020480.21684-100000@w-kevinr.svc.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
        chester.f.johnson@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Kevin W. Rudd" <ruddk@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0312101020480.21684-100000@w-kevinr.svc.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 10 Dec 2003 10:23:15 -0800 (PST)
"Kevin W. Rudd" <ruddk@us.ibm.com> wrote:

> 
> Thoughts?  Comments?

I don't think the network users will be very happy if you require changing all
end hosts this way. How about the following hack? For DF=1 packets
the ipid field is useless. When you rewrite the TOS to DSCP save
the old TOS in the ipid field.  When you see an ICMP fragment required
message with the right DSCP on the router restore the old TOS from the ipid 
field.

One drawback is that there are a few VJ header compression servers that
require changing ipid. But you can still handle these by not overwriting
all bits of ipid so that it still changes (keep a few changing bits)

-Andi
