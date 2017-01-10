From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 1/4] net: switchdev: Prepare for deferred
 functions modifying objects
Date: Tue, 10 Jan 2017 09:57:18 -0800
Message-ID: <afdaab40-1975-bb6c-eeca-dafe42d42528@gmail.com>
References: <20170109204523.5843-1-f.fainelli@gmail.com>
 <20170109204523.5843-2-f.fainelli@gmail.com>
 <20170110100901.GB1827@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        marcelo.leitner@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33877 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756081AbdAJR5U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 12:57:20 -0500
Received: by mail-pf0-f195.google.com with SMTP id y143so8840842pfb.1
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 09:57:20 -0800 (PST)
In-Reply-To: <20170110100901.GB1827@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2017 02:09 AM, Jiri Pirko wrote:
> Mon, Jan 09, 2017 at 09:45:20PM CET, f.fainelli@gmail.com wrote:
>> In preparation for adding support for deferred dump operations, allow
>> specifying a deferred function whose signature allows read/write
>> objects.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>> net/switchdev/switchdev.c | 21 ++++++++++++++++-----
>> 1 file changed, 16 insertions(+), 5 deletions(-)
>>
>> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>> index 017801f9dbaa..3d70ad02c617 100644
>> --- a/net/switchdev/switchdev.c
>> +++ b/net/switchdev/switchdev.c
>> @@ -100,11 +100,14 @@ static DEFINE_SPINLOCK(deferred_lock);
>>
>> typedef void switchdev_deferred_func_t(struct net_device *dev,
>> 				       const void *data);
>> +typedef void switchdev_deferred_func_rw_t(struct net_device *dev,
>> +					  void *data);
>>
>> struct switchdev_deferred_item {
>> 	struct list_head list;
>> 	struct net_device *dev;
>> 	switchdev_deferred_func_t *func;
>> +	switchdev_deferred_func_rw_t *func_rw;
> 
> I'm missing why you need to have 2 funcs here. Why you just can't re-use
> func?

I wanted to let the existing callers be passed down a const void *data,
and not update them with void *data, since there is value in keeping
that annotated. This may be considered overkill, I don't know.
-- 
Florian
