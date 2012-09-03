From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: Possible issue with Mellanox mlx4/port handling
Date: Mon, 03 Sep 2012 14:45:13 -0300
Message-ID: <5044ECA9.5080100@redhat.com>
References: <953B660C027164448AE903364AC447D28720CF7D@MTLDAG01.mtl.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Yevgeny Petrilin <yevgenyp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27664 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752441Ab2ICRpU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2012 13:45:20 -0400
In-Reply-To: <953B660C027164448AE903364AC447D28720CF7D@MTLDAG01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2012 02:32 PM, Yevgeny Petrilin wrote:
>> Commit
>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=4c41b3673759d096106e68bce586f103c51d4119
>> inserted changes like:
>>
>> @@ -361,7 +361,7 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8
>> port,
>>           int err;
>>           struct mlx4_priv *priv = mlx4_priv(dev);
>>
>> -       s_steer =&mlx4_priv(dev)->steer[0];
>> +       s_steer =&mlx4_priv(dev)->steer[port - 1];
>>
>>           mutex_lock(&priv->mcg_table.mutex);
>>
>> But I fear we missed one part of the deal. Concept patch:
>>
>> @@ -365,7 +365,7 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8
>> port,
>>
>>           mutex_lock(&priv->mcg_table.mutex);
>>
>> -       if (get_promisc_qp(dev, 0, steer, qpn)) {
>> +       if (get_promisc_qp(dev, port - 1, steer, qpn)) {
>>                   err = 0;  /* Noting to do, already exists */
>>                   goto out_mutex;
>>           }
>>
> ...
>>
>> As far as I can understand, we are changing a list for a port and checking for
>> duplicates on the other list. Points marked as A, B and C for highlighting. Am I
>> missing something? What do you think?
>>
>> FWIW, this call get_promisc_qp(dev, 0, ...) happens in other places too.
>>
>> Thank you,
>> Marcelo.
>
> Hi Marcelo,
> Thanks for this, You are absolutely right.
> We actually have a fix for this issue which we are now verifying, and it will be sent to the mailing list in a few days.

Hi Yevgeny,

Thanks for the fast confirmation.

If you can share, what can we expect it to be like? Like the chunk I 
suggested above or is there anything else needed? I could notice only 6 
places calling get_promisc_qp() that way and couldn't find any other 
issue like that.

Thanks,
Marcelo.
