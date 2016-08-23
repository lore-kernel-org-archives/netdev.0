From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net-next 3/3] net/sched: Introduce act_iptunnel
Date: Tue, 23 Aug 2016 19:05:37 +0300
Message-ID: <20160823160537.GB12627@office.localdomain>
References: <20160822143834.32422-1-amir@vadai.me>
 <20160822143834.32422-4-amir@vadai.me>
 <CAJ3xEMhTdNXXLQfvD097_7LEK8YRTXW_r+ArB-XksX6dRvUAjg@mail.gmail.com>
 <20160822205137.30cda14f@griffin>
 <20160823152805.GA12627@office.localdomain>
 <20160823173349.2b64b466@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34236 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752134AbcHWQYl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 12:24:41 -0400
Received: by mail-wm0-f65.google.com with SMTP id q128so18810601wma.1
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 09:22:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160823173349.2b64b466@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 23, 2016 at 05:33:49PM +0200, Jiri Benc wrote:
> On Tue, 23 Aug 2016 18:28:05 +0300, Amir Vadai wrote:
> > On Mon, Aug 22, 2016 at 08:51:37PM +0200, Jiri Benc wrote:
> > > 2. We may run into problems like tx path seeing the metadata_dst that
> > >    it should not see. This means either this situation or such
> > >    configuration must be prevented somehow.
> [...]
> > Anyway, this issue is orthogonal to this patchset...
> 
> Not really. If it's indeed (2) then such configuration needs to be
> rejected. 
The configuration that needs to be rejected is when act_iptunnel is not
used. So, I guess the fix won't be part of it...

> Or metadata_dst freed at an appropriate place. Thus it's
> something that needs to be handled by this patchset before the uAPI is
> set in stone.
It is already there - user can use act_mirred and redirect skb's with
metadata since shared tunnel devices introduced.
The only thing that was added here, is to enable the user to drop the
metadata, which I think we agree is the ok.

But I agree with you, that I must understand the life cycle of the metadata and dst
better. I will try to understand it better and explain/fix accordingly.

Again, would be happy if someone will chime in and give some hints if it
was a bug, that a user could redirect skb's with metadata, or something
harmless.

Thanks,
Amir
> 
>  Jiri
