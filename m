From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/6] Add support for offloading
 packet-sampling
Date: Thu, 13 Oct 2016 14:45:26 +0200
Message-ID: <20161013124526.GF1816@nanopsycho.orion>
References: <1476276069-5315-1-git-send-email-jiri@resnulli.us>
 <57FF37F5.4070100@cumulusnetworks.com>
 <20161013084857.GC1816@nanopsycho.orion>
 <64872c5b-8cbc-edd8-00aa-afc87a7cfa4a@mojatatu.com>
 <20161013121022.GD1816@nanopsycho.orion>
 <2cc65dfa-de32-2e31-5f03-80e8f0d2586f@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>, netdev@vger.kernel.org,
        davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        geert+renesas@glider.be, stephen@networkplumber.org,
        xiyou.wangcong@gmail.com, linux@roeck-us.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33677 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755355AbcJMMpa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 08:45:30 -0400
Received: by mail-lf0-f65.google.com with SMTP id l131so9703857lfl.0
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 05:45:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <2cc65dfa-de32-2e31-5f03-80e8f0d2586f@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 13, 2016 at 02:30:19PM CEST, jhs@mojatatu.com wrote:
>On 16-10-13 08:10 AM, Jiri Pirko wrote:
>> Thu, Oct 13, 2016 at 01:49:07PM CEST, jhs@mojatatu.com wrote:
>> > On 16-10-13 04:48 AM, Jiri Pirko wrote:
>
>[..]
>> > Roopa, did you mean eth1 as the new device or did you mean just in
>> > general config requiring a device to be specified or did you mean a new
>> > cpu netdev being needed? I couldnt tell from the patch.
>> 
>> You just have to have some netdev to use to funnel the IFE headered
>> sample skbs to userspace. A dummy or a tap.
>> 
>
>I see.
>So with nflog you get basically a backend using a netlink socket
>but in your case you will redirect to tuntap for the case of local
>sflow but some other device for remote? I am assuming using dummy
>would require a packet socket as means of retrieving the data.

Correct. The idea is that the userspace app would create a tap device,
setup the sampling packets to be sent there and recieve them
over chardev. Or the remote delivery could be use to push the sampling
packet to a remote host.


>If you take the structuring of the metadata that nflog uses it should
>be easy to transpose.

Yes, we do it with IFE, this patchset implements that.


>To Roopa's point, however: Would it not make sense to support nflog
>(in addition?).
>
>cheers,
>jamal
>
