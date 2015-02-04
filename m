From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v3 2/3] genetlink: disallow subscribing to unknown mcast groups
Date: Wed, 04 Feb 2015 16:36:11 +0100
Message-ID: <87d25pit90.fsf@nemi.mork.no>
References: <1421404634-8973-1-git-send-email-johannes@sipsolutions.net>
	<1421404634-8973-2-git-send-email-johannes@sipsolutions.net>
	<87egq5uc07.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jeff Layton <jeff.layton@primarydata.com>,
	Sedat Dilek <sedat.dilek@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:52956 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161608AbbBDPge convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 10:36:34 -0500
In-Reply-To: <87egq5uc07.fsf@nemi.mork.no> (=?utf-8?Q?=22Bj=C3=B8rn?=
 Mork"'s message of "Wed, 04
	Feb 2015 12:55:36 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork <bjorn@mork.no> writes:
> Johannes Berg <johannes@sipsolutions.net> writes:
>
>> diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
>> index 2e11061ef885..c18d3f5624b2 100644
>> --- a/net/netlink/genetlink.c
>> +++ b/net/netlink/genetlink.c
>> @@ -985,7 +985,7 @@ static struct genl_multicast_group genl_ctrl_gro=
ups[] =3D {
>> =20
>>  static int genl_bind(struct net *net, int group)
>>  {
>> -	int i, err =3D 0;
>> +	int i, err =3D -ENOENT;
>> =20
>>  	down_read(&cb_lock);
>>  	for (i =3D 0; i < GENL_FAM_TAB_SIZE; i++) {
>
> This change cause serious problems for acpid, as reported on
> https://bugzilla.kernel.org/show_bug.cgi?id=3D92121

Ah, I see this bug is already fixed by commit 8b7c36d810c6 ("netlink:
fix wrong subscription bitmask to group mapping in").  Your change was
obviously correct, and found the long standing off by one bug.  Thanks.

Sorry about the noise.  I should have checked the current "net" first.


Bj=C3=B8rn
