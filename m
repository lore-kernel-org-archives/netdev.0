From: "Rami Rosen" <roszenrami@gmail.com>
Subject: [PATCH 0/2] Multicast: add mc_count to in_device and to inet6_dev
Date: Wed, 1 Oct 2008 09:57:42 +0300
Message-ID: <b25312890809302357j6b75dd27uced2968046c10993@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	"Pekka Savola" <pekkas@netcore.fi>
To: davem@davemloft.net, "David Stevens" <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:5245 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094AbYJAG5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 02:57:44 -0400
Received: by wf-out-1314.google.com with SMTP id 27so430150wfd.4
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2008 23:57:42 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
    - This patch set adds mc_count to  struct in_device (IPv4) and to
struct inet6_dev (IPv6) and updates increment/decrement/initialization
of this field in IPv4 and in IPv6.

- Also printing the /proc entry (/proc/net/igmp) is adjusted to use
the new mc_count.

 - Thanks to David Stevens for his feedback.

Regards,
Rami Rosen

On Thu, Sep 25, 2008 at 10:35 AM, David Stevens <dlstevens@us.ibm.com> wrote:
> netdev-owner@vger.kernel.org wrote on 09/24/2008 11:44:45 PM:
>
>> Hi,
>>
>> - I had noticed a long ago that the IP addresses under
>>  /proc/net/igmp are in Hexa format. I am preparing a patch to fix it
>> and it will be send very soon.
>
> I don't think we can do that, since I believe netstat expects
> to see this the way it is. Maybe if we change netstat to support
> both and wait a year for all distros to get it... :-)
>
>
>> So indeed , the count (mc_count of netdevice) shows both IPv4 and IPv6
> igmp
>> groups, but in current implementation it is not immediate
>> to change it. Currently, net_device struct does not have specific
>> fields for ipv4 or ipv6.  One way of preparing a patch
>> is to change net_device to have mc_count4 and mc_count6;
>> I am really willing to prepare such a patch, but I am not sure such a
>> change in net_device is a proper and a justified
>> change to do.
>
>        These belong with mc_list in inet6_dev and in_device. Really,
> I'd just add "mc_count" as a field right next to mc_list and inc/dec
> it when calling the group join/leave functions-- use the list lock
> to protect it. The structure it's in distinguishes the protocol,
> and the names are otherwise common.
>
>                                                                +-DLS
>
>
