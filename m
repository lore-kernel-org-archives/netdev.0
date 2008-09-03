From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: v3 [PATCH 1/1] dccp: Process incoming Change	feature-negotiation
 options
Date: Wed, 03 Sep 2008 14:03:23 +0800
Message-ID: <48BE28AB.8040905@cn.fujitsu.com>
References: <1219339188-31873-1-git-send-email-gerrit@erg.abdn.ac.uk> <1219339188-31873-2-git-send-email-gerrit@erg.abdn.ac.uk> <1219339188-31873-3-git-send-email-gerrit@erg.abdn.ac.uk> <1219339188-31873-4-git-send-email-gerrit@erg.abdn.ac.uk> <20080823105647.GA15928@gerrit.erg.abdn.ac.uk> <48BCE45E.1080709@cn.fujitsu.com> <20080903042709.GB4105@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Wei Yongjun <yjwei@cn.fujitsu.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54281 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751896AbYICGGH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 02:06:07 -0400
In-Reply-To: <20080903042709.GB4105@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gerrit Renker wrote:
>>> +	/*
>>> +	 *	Unidirectional/simultaneous negotiation of SP features (6.3.1)
>>> +	 */
>>> +	entry = dccp_feat_list_lookup(fn, feat, local);
>>> +	if (entry == NULL) {
>>> +		if (!dccp_feat_sp_list_ok(feat, val, len))
>>> +			goto unknown_feature_or_value;
>>>   
>>>       
>> Check for sp feat list should before code "entry =  
>> dccp_feat_list_lookup(fn, feat, local);",
>> here only check for features not register by local endpoint, if the  
>> feature is registed, the validity check is missing?
>>
>>     
> +
> No, in this case the validity check is performed already as part of the socket
> registration routines - which in turn end up calling dccp_feat_sp_list_ok.  
> If a user tries to register invalid SP values on the socket, the attempt
> will fail with EINVAL. If the user does not register values, the feature
> defaults (6.4) are used, which are valid by definition.
> The host is conservative in what it allows to send out.
>   

The socket registration routines check the feature values local set, but 
this place is check
the features we *received* from other endpoints.

I agree with you here do not need chec as your other mail said:
RFC4340 6.6.8
Note that server-priority features do not have value limitations, since
unknown values are handled as a matter of course.

May be this check "if (!dccp_feat_sp_list_ok(feat, val, len))" is too 
strictly for known
sp features but not registed by socket.


