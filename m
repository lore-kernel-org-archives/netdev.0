From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH 2/9] net-ethtool: Convert (hw_/vlan_/wanted_)features
 fields from u32 type to u64.
Date: Mon, 25 Apr 2011 11:14:16 -0700
Message-ID: <BANLkTinNORHLJ_YqzMmFZo9v7CjS+ZrhWA@mail.gmail.com>
References: <1303515367-25595-1-git-send-email-maheshb@google.com>
	<1303515367-25595-2-git-send-email-maheshb@google.com>
	<1303515367-25595-3-git-send-email-maheshb@google.com>
	<1303623041.3032.97.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:9272 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758203Ab1DYSOU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 14:14:20 -0400
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p3PIEIDh000497
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 11:14:18 -0700
Received: from bwz14 (bwz14.prod.google.com [10.188.26.14])
	by hpaq12.eem.corp.google.com with ESMTP id p3PIDd8W013668
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 11:14:17 -0700
Received: by bwz14 with SMTP id 14so2942842bwz.16
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 11:14:17 -0700 (PDT)
In-Reply-To: <1303623041.3032.97.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 23, 2011 at 10:30 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Fri, 2011-04-22 at 16:36 -0700, Mahesh Bandewar wrote:
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>> =A0include/linux/ethtool.h | =A0 26 +++++++------
>> =A0net/core/ethtool.c =A0 =A0 =A0| =A0 89 ++++++++++++++++----------=
--------------------
>> =A02 files changed, 45 insertions(+), 70 deletions(-)
>>
>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>> index 9de3127..71e8a02 100644
>> --- a/include/linux/ethtool.h
>> +++ b/include/linux/ethtool.h
>> @@ -605,10 +605,10 @@ struct ethtool_flash {
>> =A0 * @never_changed: mask of features not changeable for any device
>> =A0 */
>> =A0struct ethtool_get_features_block {
>> - =A0 =A0 __u32 =A0 available;
>> - =A0 =A0 __u32 =A0 requested;
>> - =A0 =A0 __u32 =A0 active;
>> - =A0 =A0 __u32 =A0 never_changed;
>> + =A0 =A0 __u64 =A0 available;
>> + =A0 =A0 __u64 =A0 requested;
>> + =A0 =A0 __u64 =A0 active;
>> + =A0 =A0 __u64 =A0 never_changed;
>> =A0};
>>
>> =A0/**
>> @@ -618,10 +618,11 @@ struct ethtool_get_features_block {
>> =A0 * =A0 =A0 =A0 out: number of elements in features[] needed to ho=
ld all features
>> =A0 * @features: state of features
>> =A0 */
>> +/* TODO Why is this needed XXX */
>
> Precisely to allow for expansion to more than 32 bits.
>
:) That comment was not supposed to be part of the patch and was just
to aid my thinking while we were discussing about the approach to
extend features. (I thought) if we have decided not to use use arrays,
then why to complicate this interface, so was attempting to simplify
the interface.

>> =A0struct ethtool_gfeatures {
>> =A0 =A0 =A0 __u32 =A0 cmd;
>> =A0 =A0 =A0 __u32 =A0 size;
>> - =A0 =A0 struct ethtool_get_features_block features[0];
>> + =A0 =A0 struct ethtool_get_features_block features;
>> =A0};
>>
>> =A0/**
>> @@ -630,8 +631,8 @@ struct ethtool_gfeatures {
>> =A0 * @requested: values of features to be changed
>> =A0 */
>> =A0struct ethtool_set_features_block {
>> - =A0 =A0 __u32 =A0 valid;
>> - =A0 =A0 __u32 =A0 requested;
>> + =A0 =A0 __u64 =A0 valid;
>> + =A0 =A0 __u64 =A0 requested;
>> =A0};
>>
>> =A0/**
>> @@ -640,10 +641,11 @@ struct ethtool_set_features_block {
>> =A0 * @size: array size of the features[] array
>> =A0 * @features: feature change masks
>> =A0 */
>> +/* TODO Why is this needed XXX */
>> =A0struct ethtool_sfeatures {
>> =A0 =A0 =A0 __u32 =A0 cmd;
>> =A0 =A0 =A0 __u32 =A0 size;
>> - =A0 =A0 struct ethtool_set_features_block features[0];
>> + =A0 =A0 struct ethtool_set_features_block features;
>> =A0};
> [...]
>
> These structures are part of the userland API, but they are new in
> 2.6.39. =A0So they can still be changed up until 2.6.39 is released, =
but
> not afterwards.
>
got it!

> If we think 64 bits will be enough for the next 10 years, then let's
> just go with a single 64-bit feature word. =A0If we're not so sure th=
en
> then the ethtool API should continue to allow for multiple words
> (whether 32-bit or 64-bit).
>
I think even 64 bits may not be enough, so in the earlier thread I had
mentioned that, this would (probably) give us next two years! I didn't
know this constraint though.

--mahesh..

> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
