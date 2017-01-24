From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH cumulus-4.1.y 2/5] vxlan: don't replace fdb entry if nothing
 changed
Date: Mon, 23 Jan 2017 16:14:09 -0800
Message-ID: <58869C51.4080101@cumulusnetworks.com>
References: <1484984410-3304-1-git-send-email-roopa@cumulusnetworks.com> <1484984410-3304-2-git-send-email-roopa@cumulusnetworks.com> <20170123090211.6bcd2afc@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        ramanb@cumulusnetworks.com, jbenc@redhat.com, pshelar@ovn.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33705 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750846AbdAXAVk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 19:21:40 -0500
Received: by mail-pg0-f42.google.com with SMTP id 204so49270955pge.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 16:21:40 -0800 (PST)
In-Reply-To: <20170123090211.6bcd2afc@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/17, 9:02 AM, Stephen Hemminger wrote:
> On Fri, 20 Jan 2017 23:40:07 -0800
> Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>
>> +	if (!vxlan_addr_equal(&rd->remote_ip, ip) ||
>> +	    rd->remote_port != port ||
>> +	    rd->remote_vni != vni ||
>> +	    rd->remote_ifindex != ifindex) {
>> +		dst_cache_reset(&rd->dst_cache);
>> +		rd->remote_ip = *ip;
>> +		rd->remote_port = port;
>> +		rd->remote_vni = vni;
>> +		rd->remote_ifindex = ifindex;
>> +		return 1;
>> +	}
>> +
> I think it would be clearer if negative logic was avoided.
>
> 	if (vxlan_addr_equal(&rd->remote_ip, ip) &&
> 	    rd->remote_port == port &&
> 	    rd->remote_vni == vni &&
>             rd->ermote_ifindex == ifndex)
> 		return 1;
>
> 	dst_cache_reset ...

ack, this was an accidental hit on send as well.
It is on my upstream patch stack..but i think this patch is not really needed upstream because
a previous call to vxlan_fdb_find_rdst in vxlan_fdb_replace does the same thing.

I will test again and repost if needed, thanks.
