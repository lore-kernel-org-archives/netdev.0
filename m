From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH net-next] tun: Add ability to create tun device with given
 index
Date: Fri, 14 Jun 2013 13:34:28 +0400
Message-ID: <51BAE3A4.2030609@parallels.com>
References: <51B99946.3000703@parallels.com> <20130613095248.68c52109@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:13887 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751120Ab3FNJek (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jun 2013 05:34:40 -0400
In-Reply-To: <20130613095248.68c52109@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2013 08:52 PM, Stephen Hemminger wrote:
> On Thu, 13 Jun 2013 14:04:54 +0400
> Pavel Emelyanov <xemul@parallels.com> wrote:
> 
>> Tun devices cannot be created with ifidex user wants, but it's
>> required by checkpoint-restore project.
>>
>> Long time ago such ability was implemented for rtnl_ops-based
>> interface for creating links (9c7dafbf net: Allow to create links
>> with given ifindex), but the only API for creating and managing 
>> tuntap devices is ioctl-based and is evolving with adding new ones
>> (cde8b15f tuntap: add ioctl to attach or detach a file form tuntap
>> device).
>>
>> Following that trend, here's how a new ioctl that sets the ifindex
>> for device, that _will_ be created by TUNSETIFF ioctl looks like.
>> So those who want a tuntap device with the ifindex I, should open
>> the tun device, call ioctl(fd, TUNSETIFINDEX, I), then call TUNSETIFF.
>> If setifindex is not called, then it will be generated as before.
>>
>> Is it OK to extend ioctls with this, or should we rather switch the
>> whole tuntap driver on full-featured rtln-ops?
>>
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>>
> 
> I see no check for the most fundamental thing, the ifindex must be unique!
> 

The register_netdev() will check for this and report -EBUSY if it is (and
add device to list if not, all atomically).

Thanks,
Pavel
