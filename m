From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 0/6] Add support for offloading packet-sampling
Date: Thu, 13 Oct 2016 00:29:57 -0700
Message-ID: <57FF37F5.4070100@cumulusnetworks.com>
References: <1476276069-5315-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33112 "EHLO
        mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752987AbcJMKC7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 06:02:59 -0400
Received: by mail-pa0-f45.google.com with SMTP id vu5so37361267pab.0
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 03:02:59 -0700 (PDT)
In-Reply-To: <1476276069-5315-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/16, 5:41 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Add the sample tc action, which allows to sample packet matching
> a classifier. The sample action peeks randomly packets, duplicates them,
> truncates them and adds informative metadata on the packet, for example,
> the input interface and the original packet length. The sampled packets
> are marked to allow matching them and redirecting them to a specific
> collector device.
>
> The sampled packets metadata is packed using ife encapsulation. To do
> that, this patch-set extracts ife logics from the tc_ife action into an
> independent ife module, and uses that functionality to pack the metadata.
> To include all the needed metadata, this patch-set introduces some new
> IFE_META tlv types.
>
> In addition, Add the support for offloading the matchall-sample tc command
> in the Mellanox mlxsw driver, for ingress qdiscs.
>
> Yotam Gigi (6):
>   Introduce ife encapsulation module
>   act_ife: Change to use ife module
>   ife: Introduce new metadata tlv types
>   Introduce sample tc action
>   mlxsw: reg: add the Monitoring Packet Sampling Configuration Register
>   mlxsw: packet sample: Add packet sample offloading support
>

we spoke with yotam about this at netdev1.2. and also remember speaking about this on our switchdev calls:
Today our driver uses NFLOG to log packets to a netlink socket and hsflowd supported by the sflow
people (at http://www.sflow.net/) is capable of reading from a nflog socket. NFLOG has the required netlink
attribute markers for packet header/data (which we can possibly extend). We could also add nflog like action
in tc if needed.

sflow agents like hsflowd are capable of sending packets to an external collector with the required sflow header.
Instead of re-inventing a new API for sflow, would be better to standardize/unify on existing mechanisms.

Also, this patch series requires a new device to be created which can be avoided if we used
existing mechanisms like NFLOG.
