From: Glen Turner <glen.turner@aarnet.edu.au>
Subject: Re: [PATCH 2.6] vlan ioctl propagation (rev.2)
Date: Sun, 08 Aug 2004 14:08:36 +0930
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4115AE4C.2060608@aarnet.edu.au>
References: <20040806091305.4d405664@dell_ss3.pdx.osdl.net> <20040806132145.675fd17d.davem@redhat.com> <20040806143928.711d92eb@dell_ss3.pdx.osdl.net> <20040807211036.GA7970@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20040807211036.GA7970@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

bert hubert wrote:

> On Fri, Aug 06, 2004 at 02:39:28PM -0700, Stephen Hemminger wrote:
> 
>>Here is a redo of the patch to propagate ethtool and mii ioctl's
>>on vlan's to the underlying real device.  This time the request
>>is copied to a new buffer, to avoid the colon name rewrite issues.
> 
> 
> Is this really what we want? We also don't make virtual IPs appear as real
> interfaces anymore. Virtual devices are just that - virtual.

Hi Bert,

Please don't be so absolute. For example, if the virtual device "link" status
doesn't reflect that of the real device then routing software needs to parse
the virtual->real device mappings (a parsing for which Linux provides only
limited support).

Worse still, we now need to special-case virtual interfaces in application
code:
    while (virtual_interface(interface_name)) {
      virtual_to_real(interface_name, &interface_name);
    }

This is the sort of nasty detail than operating systems are meant to abstract
away from application code.

Thanks,
Glen
