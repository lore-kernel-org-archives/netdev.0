From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] mpls: support for dead routes
Date: Tue, 03 Nov 2015 06:56:00 -0800
Message-ID: <5638CB00.4010803@cumulusnetworks.com>
References: <201511030632.M6iNpQTU%fengguang.wu@intel.com> <alpine.DEB.2.02.1511030810310.2043@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com, davem@davemloft.net,
	netdev@vger.kernel.org, kbuild-all@01.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34628 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbbKCO4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 09:56:04 -0500
Received: by padhx2 with SMTP id hx2so12785585pad.1
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 06:56:03 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1511030810310.2043@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks fixed in v3.

On 11/2/15, 11:11 PM, Julia Lawall wrote:
> Please check on what was intended.
>
> julia
>
> On Tue, 3 Nov 2015, kbuild test robot wrote:
>
>> CC: kbuild-all@01.org
>> In-Reply-To: <1446498529-50275-1-git-send-email-roopa@cumulusnetworks.com>
>> TO: Roopa Prabhu <roopa@cumulusnetworks.com>
>> CC: ebiederm@xmission.com, rshearma@brocade.com, davem@davemloft.net, netdev@vger.kernel.org
>> CC: davem@davemloft.net, netdev@vger.kernel.org
>>
>> Hi Roopa,
>>
>> [auto build test WARNING on net-next/master -- if it's inappropriate base, please suggest rules for selecting the more suitable base]
>>
>> url:    https://github.com/0day-ci/linux/commits/Roopa-Prabhu/mpls-support-for-dead-routes/20151103-051211
>> :::::: branch date: 88 minutes ago
>> :::::: commit date: 88 minutes ago
>>
>>>> net/mpls/af_mpls.c:702:6-22: duplicated argument to && or ||
>> git remote add linux-review https://github.com/0day-ci/linux
>> git remote update linux-review
>> git checkout 21fa92d07a7254a2042ded6647fc4b91332c6d0e
>> vim +702 net/mpls/af_mpls.c
>>
>> f8efb73c Roopa Prabhu    2015-10-23  686  	int nhs = 0;
>> f8efb73c Roopa Prabhu    2015-10-23  687  	int err = 0;
>> f8efb73c Roopa Prabhu    2015-10-23  688  
>> f8efb73c Roopa Prabhu    2015-10-23  689  	change_nexthops(rt) {
>> f8efb73c Roopa Prabhu    2015-10-23  690  		int attrlen;
>> f8efb73c Roopa Prabhu    2015-10-23  691  
>> f8efb73c Roopa Prabhu    2015-10-23  692  		nla_via = NULL;
>> f8efb73c Roopa Prabhu    2015-10-23  693  		nla_newdst = NULL;
>> f8efb73c Roopa Prabhu    2015-10-23  694  
>> f8efb73c Roopa Prabhu    2015-10-23  695  		err = -EINVAL;
>> f8efb73c Roopa Prabhu    2015-10-23  696  		if (!rtnh_ok(rtnh, remaining))
>> f8efb73c Roopa Prabhu    2015-10-23  697  			goto errout;
>> f8efb73c Roopa Prabhu    2015-10-23  698  
>> 1c78efa8 Robert Shearman 2015-10-23  699  		/* neither weighted multipath nor any flags
>> 1c78efa8 Robert Shearman 2015-10-23  700  		 * are supported
>> 1c78efa8 Robert Shearman 2015-10-23  701  		 */
>> 21fa92d0 Roopa Prabhu    2015-11-02 @702  		if (rtnh->rtnh_flags || rtnh->rtnh_flags)
>> 1c78efa8 Robert Shearman 2015-10-23  703  			goto errout;
>> 1c78efa8 Robert Shearman 2015-10-23  704  
>> f8efb73c Roopa Prabhu    2015-10-23  705  		attrlen = rtnh_attrlen(rtnh);
>> f8efb73c Roopa Prabhu    2015-10-23  706  		if (attrlen > 0) {
>> f8efb73c Roopa Prabhu    2015-10-23  707  			struct nlattr *attrs = rtnh_attrs(rtnh);
>> f8efb73c Roopa Prabhu    2015-10-23  708  
>> f8efb73c Roopa Prabhu    2015-10-23  709  			nla_via = nla_find(attrs, attrlen, RTA_VIA);
>> f8efb73c Roopa Prabhu    2015-10-23  710  			nla_newdst = nla_find(attrs, attrlen, RTA_NEWDST);
>>
>> ---
>> 0-DAY kernel test infrastructure                Open Source Technology Center
>> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>>
