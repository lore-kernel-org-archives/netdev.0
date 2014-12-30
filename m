From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH 6/6] bridge: add vlan info to bridge setlink and dellink
 notification messages
Date: Mon, 29 Dec 2014 21:25:01 -0800
Message-ID: <CAE4R7bC406Vn_vCnbmoDNGMhNZTcO_sUu5CdOU7iefVOBZ-z6A@mail.gmail.com>
References: <1419887132-7084-7-git-send-email-roopa@cumulusnetworks.com>
	<CAE4R7bCnqBX8TWmG4O_wppKtbnnCEWaaz+bHreybd8pPfUPs+w@mail.gmail.com>
	<54A2355B.6060903@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, shemminger@vyatta.com,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:60720 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbaL3FZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 00:25:03 -0500
Received: by mail-we0-f177.google.com with SMTP id q59so495935wes.36
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 21:25:01 -0800 (PST)
In-Reply-To: <54A2355B.6060903@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 29, 2014 at 9:17 PM, roopa <roopa@cumulusnetworks.com> wrote:
> On 12/29/14, 3:42 PM, Scott Feldman wrote:
>>
>> On Mon, Dec 29, 2014 at 1:05 PM,  <roopa@cumulusnetworks.com> wrote:
>>>
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> vlan add/deletes are not notified to userspace today. This patch fixes
>>> it.
>>> Notifications will contain vlans compressed into ranges whereever
>>> applicable.
>>
>> Why is this notification needed?  On VLAN add/del, the port driver
>> will already get called if it implements ndo_vlan_rx_add_vid and
>> ndo_vlan_rx_kill_vid.
>
> This is strictly for userspace.
>
>>    The port driver already gets the notification
>> it needs to filter vlans.  User space can query for vlan port
>> membership if it needs to know.
>
>
> You mean request a dump ?. yes it can if it needs all the configured vlans.
> But for notifications, we must at the least notify what changed with respect
> to vlans with RTM_SETLINK/DELLINK, no ?

You'll get that notification if you implement ndo_vlan_rx_add/kill_vid
in your port driver, which is called from RTM_SETLINK/DELLINK.  Your
port driver can send to user-space, I suppose, if user-space needs
notification.
