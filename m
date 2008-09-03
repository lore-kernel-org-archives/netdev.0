From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 07/37] dccp: Registration routines for changing feature
	values
Date: Wed, 3 Sep 2008 06:46:04 +0200
Message-ID: <20080903044604.GE4105@gerrit.erg.abdn.ac.uk>
References: <1219945512-7723-2-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-3-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-4-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-5-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-6-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-7-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-8-git-send-email-gerrit@erg.abdn.ac.uk> <20080828205447.GN9193@ghostprotocols.net> <20080829061237.GD3557@gerrit.erg.abdn.ac.uk> <48BCD945.1020009@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:40696 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750890AbYICEqY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 00:46:24 -0400
Content-Disposition: inline
In-Reply-To: <48BCD945.1020009@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> | > +/* check that SP values are within the ranges defined in RFC 4340 */
>> | > +static u8 dccp_feat_is_valid_sp_val(u8 feat_num, u8 val)
>> | > +{
<snip>	
>> In the CCID-4 subtree, the above statement changes to
>>  | > +		val >= DCCPC_CCID2 && val <= DCCPC_CCID4;
>>   
>
> This may cause DCCP client which support only CCID 2 and CCID 3 can not  
> connect to a DCCP server which support CCID2 to CCID4.
>
> See as following:
>
> DCCP client                    DCCP server
> REQUEST           ------->
> (CHANGE_R/CCID 2 3)
>                  <-------     RESPONSE
>                               (CONFIRM_R/CCID 2 2 3 4)
>
>
> RESPONSE from DCCP server with CONFIRM_R(CCID 2 2 3 4) will cause DCCP  
> client send a reset to DCCP server.
>
> This is because dccp_feat_confirm_recv() will check whether the feat  
> list is valid before accept the CCID.
>
> static u8 dccp_feat_confirm_recv(struct list_head *fn, u8 is_mandatory,  
> u8 opt, ... {
>    ...
>    if (!dccp_feat_sp_list_ok(feat, val, len))
>        goto confirmation_failed;
>    ...
> }
>
Excellent catch, but the problem you point out is not in the range of
CCID values. It means that the validity checking for SP values in
general is too restrictive: the same problem will reappear not only
for CCIDs, but for all SP features that could have values in the Confirm
list which may locally be unknown. It is also not what 6.6.8 says:
  "Note that server-priority features do not have value limitations,
   since unknown values are handled as a matter of course."

So thank you I will restrict the validity check to the confirmed value only.

Gerrit
