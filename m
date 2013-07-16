From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [patch net-next v2] nlmon: use standard rtnetlink link api for
 add/del devices
Date: Tue, 16 Jul 2013 16:49:53 +0200
Message-ID: <51E55D91.5050000@redhat.com>
References: <1372755331-1267-1-git-send-email-jiri@resnulli.us> <loom.20130716T160603-964@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>
To: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932536Ab3GPOt6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jul 2013 10:49:58 -0400
In-Reply-To: <loom.20130716T160603-964@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/16/2013 04:08 PM, Vladimir Kondratiev wrote:
> Jiri Pirko <jiri <at> resnulli.us> writes:
>
>> It is not nice when netdev is created right after module load and with
>> some implicit name. So rather change nlmon to use standard rtnl link API.
>
> Could you please elaborate a bit - how to capture netlink skb's after your
> patch? Before, it was netdev that may be used with tcpdump. Now, there is
> no such netdev. How to create it?

modprobe nlmon
ip link add type nlmon
ip link set nlmon0 up

tcpdump -i nlmon0 ....

ip link set nlmon0 down
ip link del dev nlmon0
rmmod nlmon
