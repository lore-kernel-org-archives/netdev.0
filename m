From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/6] Add support for offloading
 packet-sampling
Date: Thu, 13 Oct 2016 14:10:22 +0200
Message-ID: <20161013121022.GD1816@nanopsycho.orion>
References: <1476276069-5315-1-git-send-email-jiri@resnulli.us>
 <57FF37F5.4070100@cumulusnetworks.com>
 <20161013084857.GC1816@nanopsycho.orion>
 <64872c5b-8cbc-edd8-00aa-afc87a7cfa4a@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>, netdev@vger.kernel.org,
        davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        geert+renesas@glider.be, stephen@networkplumber.org,
        xiyou.wangcong@gmail.com, linux@roeck-us.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35435 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755316AbcJMMLJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 08:11:09 -0400
Received: by mail-lf0-f68.google.com with SMTP id x79so12418049lff.2
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 05:10:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <64872c5b-8cbc-edd8-00aa-afc87a7cfa4a@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 13, 2016 at 01:49:07PM CEST, jhs@mojatatu.com wrote:
>On 16-10-13 04:48 AM, Jiri Pirko wrote:
>> Thu, Oct 13, 2016 at 09:29:57AM CEST, roopa@cumulusnetworks.com wrote:
>> > On 10/12/16, 5:41 AM, Jiri Pirko wrote:
>> > > From: Jiri Pirko <jiri@mellanox.com>
>> > > 
>[..]
>> > 
>> > we spoke with yotam about this at netdev1.2. and also remember speaking about this on our switchdev calls:
>> > Today our driver uses NFLOG to log packets to a netlink socket and hsflowd supported by the sflow
>> > people (at http://www.sflow.net/) is capable of reading from a nflog socket. NFLOG has the required netlink
>> > attribute markers for packet header/data (which we can possibly extend). We could also add nflog like action
>> > in tc if needed.
>> > 
>> > sflow agents like hsflowd are capable of sending packets to an external collector with the required sflow header.
>> > Instead of re-inventing a new API for sflow, would be better to standardize/unify on existing mechanisms.
>> > 
>> > Also, this patch series requires a new device to be created which can be avoided if we used
>> > existing mechanisms like NFLOG.
>> 
>> When I was first thinking about re-using NFLOG, it seemed like an
>> abusal. We need to call it from driver directly, which sounds odd.
>> However, since we use sample_packet_pack function to wrap it up, the
>> NFLOG is called from the tc action code, it does not look bad.
>> Yet still, this has nothing in common with netfilter, only using it's
>> log facilities. That is odd.
>> 
>
>Sorry, had not seen the code until now; helps me get perspective.
>If you are going to require  netfilter just so you can do this - it
>sounds so wrong (since you already provides a hook for tc offloading
>into the switch for other functions).

+1


>Roopa, did you mean eth1 as the new device or did you mean just in
>general config requiring a device to be specified or did you mean a new
>cpu netdev being needed? I couldnt tell from the patch.

You just have to have some netdev to use to funnel the IFE headered
sample skbs to userspace. A dummy or a tap.


>
>> I think that the IFE ways is way more clear and generic and not-abusing.
>> However you are right the NFLOG way has advantage of existing user
>> component. I'm not sure how to do this :(
>
>Can you do NFLOG to user space without requiring netfilter compiled in?
>One advantage with IFE is it is a wire protocol - so you can have the
>sflow collector/aggregator sit on a different machine (for small cpu
>switches makes sense). So modifying the sflow daemon to accept IFE
>formatted data is an interesting!

Agreed. For me, that looks like the correct way to do this.


>
>cheers,
>jamal
