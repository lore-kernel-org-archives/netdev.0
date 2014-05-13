From: Cong Wang <cwang@twopensource.com>
Subject: Re: Problem with iflink in netns
Date: Tue, 13 May 2014 11:20:58 -0700
Message-ID: <CAHA+R7NX8BoXHkSZ97+op7Leg3nD_=TFjJ1K3wSr3pWQbF4Eug@mail.gmail.com>
References: <20140513083945.062de6c3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:59271 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277AbaEMSU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 14:20:59 -0400
Received: by mail-la0-f47.google.com with SMTP id pn19so585666lab.20
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 11:20:58 -0700 (PDT)
In-Reply-To: <20140513083945.062de6c3@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 13, 2014 at 8:39 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> There have been a couple of bugzilla reports already about cases where a macvlan
> or vlan is moved into another namespace. In these cases the parent device ifindex (iflink)
> is no longer valid.
>
>
> Normally it is not a big issue, until another device is created using the ifindex
> of the parent
>
> Does anyone have a suggested fix? Marking iflink as 0 won't work then the devices no
> longer appear as slaves. Another possibility would be to make block creation of device
> where ifindex matches existing iflink of other devices; but this would slow down device
> creation.
>

I have a pending fix which converts ->iflink to a pointer to struct net_device,
this is a suggested fix from Ben. And so, when the lower device is not
in the same
namespace with the upper device, we should not display the iflink information.

I will send it soon.
