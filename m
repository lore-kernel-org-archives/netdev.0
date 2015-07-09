From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 4/5] rocker: add offload_fwd_mark support
Date: Wed, 8 Jul 2015 22:35:09 -0700
Message-ID: <CAE4R7bBJuaT_1P5CoxmkijcTJ+7hw9uvjbUCK3EDZK0DHdjX-Q@mail.gmail.com>
References: <1436397403-62412-1-git-send-email-sfeldma@gmail.com>
 <1436397403-62412-5-git-send-email-sfeldma@gmail.com> <20150709042606.GA16603@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:33427 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700AbbGIFf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 01:35:29 -0400
Received: by oiyy130 with SMTP id y130so182065457oiy.0
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 22:35:28 -0700 (PDT)
In-Reply-To: <20150709042606.GA16603@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 8, 2015 at 9:26 PM, Simon Horman <simon.horman@netronome.com> wrote:
> Hi Scott,
>
> On Wed, Jul 08, 2015 at 04:16:42PM -0700, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> If device flags ingress packet as "fwd offload", mark the
>> skb->offlaod_fwd_mark using the ingress port's dev->offlaod_fwd_mark.  This
>> will be the hint to the kernel that this packet has already been forwarded
>> by device to egress ports matching skb->offlaod_fwd_mark.
>>
>> For rocker, derive port dev->offlaod_fwd_mark based on device switch ID and
>> port ifindex.  If port is bridged, use the bridge ifindex rather than the
>> port ifindex.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>
> [snip]
>
>> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>> index c005167..a4ced91 100644
>> --- a/drivers/net/ethernet/rocker/rocker.c
>> +++ b/drivers/net/ethernet/rocker/rocker.c
>
> [snip]
>
>> @@ -4938,11 +4944,13 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
>>       }
>>       rocker->ports[port_number] = rocker_port;
>>
>> +     switchdev_port_fwd_mark_set(rocker_port->dev, NULL, false);
>> +
>>       rocker_port_set_learning(rocker_port, SWITCHDEV_TRANS_NONE);
>>
>>       err = rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE, 0);
>>       if (err) {
>> -             dev_err(&pdev->dev, "install ig port table failed\n");
>> +             netdev_err(rocker_port->dev, "install ig port table failed\n");
>>               goto err_port_ig_tbl;
>>       }
>
> It is unclear to me how the above *_err change and...
>
>>
>> @@ -4962,6 +4970,7 @@ err_untagged_vlan:
>>       rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE,
>>                          ROCKER_OP_FLAG_REMOVE);
>>  err_port_ig_tbl:
>> +     rocker->ports[port_number] = NULL;
>>       unregister_netdev(dev);
>>  err_register_netdev:
>>       free_netdev(dev);
>
> ... the above ports[] change relate to the rest of this patch.

Not related; I'll pull those out for v2 and send under separate cover.
Thanks for reviewing.
