From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: Re: [PATCH 2/2] ip_tunnel: add mpls over gre encapsulation
Date: Thu, 21 Sep 2017 23:39:13 +0200
Message-ID: <dd6e449c-af1b-47ad-5bfb-1406a711b609@6wind.com>
References: <1505985924-12479-1-git-send-email-amine.kherbouche@6wind.com>
 <1505985924-12479-3-git-send-email-amine.kherbouche@6wind.com>
 <20170921212536.GA814@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xeb@mail.ru, roopa@cumulusnetworks.com,
        equinox@diac24.net
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:43052 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdIUVjJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 17:39:09 -0400
Received: by mail-wr0-f180.google.com with SMTP id a43so5546724wrc.0
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 14:39:09 -0700 (PDT)
In-Reply-To: <20170921212536.GA814@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francois,

Thanks for the feedback, I'll make it for the next version.

On 21/09/2017 23:25, Francois Romieu wrote:
> Amine Kherbouche <amine.kherbouche@6wind.com> :
> [...]
>> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
>> index 36ea2ad..060ed07 100644
>> --- a/net/mpls/af_mpls.c
>> +++ b/net/mpls/af_mpls.c
> [...]
>> @@ -39,6 +40,40 @@ static int one = 1;
>>   static int label_limit = (1 << 20) - 1;
>>   static int ttl_max = 255;
>>   
>> +size_t ipgre_mpls_encap_hlen(struct ip_tunnel_encap *e)
>> +{
>> +	return sizeof(struct mpls_shim_hdr);
>> +}
>> +
>> +int ipgre_mpls_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
>> +			    u8 *protocol, struct flowi4 *fl4)
>> +{
>> +	return 0;
>> +}
>> +
>> +static const struct ip_tunnel_encap_ops mpls_iptun_ops = {
>> +	.encap_hlen = ipgre_mpls_encap_hlen,
>> +	.build_header = ipgre_mpls_build_header,
>> +};
> Nit: af_mpls.c uses tab before '=' in such places.
>
>> +
>> +int ipgre_tunnel_encap_add_mpls_ops(void)
>> +{
>> +	int ret;
>> +
>> +	ret = ip_tunnel_encap_add_ops(&mpls_iptun_ops, TUNNEL_ENCAP_MPLS);
> ip_tunnel_encap_add_ops is CONFIG_NET_IP_TUNNEL dependant.
>
> Afaics CONFIG_MPLS does not enforce it.
>
> [...]
>> @@ -2486,6 +2521,7 @@ static int __init mpls_init(void)
>>   		      0);
>>   	rtnl_register(PF_MPLS, RTM_GETNETCONF, mpls_netconf_get_devconf,
>>   		      mpls_netconf_dump_devconf, 0);
>> +	ipgre_tunnel_encap_add_mpls_ops();
>>   	err = 0;
>>   out:
>>   	return err;
> ipgre_tunnel_encap_add_mpls_ops status return code is not checked.
>
