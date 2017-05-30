From: Jiri Benc <jbenc@redhat.com>
Subject: Re: vxlan: use after free error
Date: Tue, 30 May 2017 13:53:02 +0200
Message-ID: <20170530135302.5ecaec88@griffin>
References: <03ac7d79-02b7-4bee-d318-9731413bf97b@mellanox.com>
        <CAJieiUhNV7=r53mmsHTHAmA8g0PKoxszHyNMXwYKG4OsB20KjQ@mail.gmail.com>
        <b04f5f7e-dca1-b219-eb52-03f58fd3823e@mellanox.com>
        <CAJieiUgwRT8NbNdZ37HXJn9OYc78bpj=Zb9N5pQQQ_SLZhD1kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark Bloch <markb@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        pravin shelar <pshelar@ovn.org>,
        Alexander Duyck <aduyck@mirantis.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Balki Raman <ramanb@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53176 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750912AbdE3LxH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 May 2017 07:53:07 -0400
In-Reply-To: <CAJieiUgwRT8NbNdZ37HXJn9OYc78bpj=Zb9N5pQQQ_SLZhD1kg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 May 2017 11:37:22 -0700, Roopa Prabhu wrote:
> What you say looks correct..., but does not hurt to leave this check in there..
> given rest of the changes you are proposing below.

I agree with Mark that the check is superfluous and should not be there.

> Looking at git blame, this check was added for OVS in dellink...but it
> could have been because
>  it was being called before stop in dellink.

The code at that time did not use rtnl ops to create/delete the tunnel
and was refactored meanwhile. The conditions from that time do not hold
anymore.

> That seems right. It does look redundant if we hit the same code via
> vxlan_stop during dellink.
> 
> This code is also hit via the OVS path, and i don't see a problem with
> your changes and analysis but i am not too familiar with the ovs call
> path. I see that the relevant developers are CC'ed.

I think it's okay.

Thanks!

 Jiri
