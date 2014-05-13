From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Problem with iflink in netns
Date: Tue, 13 May 2014 13:05:54 -0700
Message-ID: <20140513130554.2e452af8@nehalam.linuxnetplumber.net>
References: <20140513083945.062de6c3@nehalam.linuxnetplumber.net>
	<CAHA+R7NX8BoXHkSZ97+op7Leg3nD_=TFjJ1K3wSr3pWQbF4Eug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:37519 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348AbaEMUF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 16:05:58 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb1so673214pad.23
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 13:05:58 -0700 (PDT)
In-Reply-To: <CAHA+R7NX8BoXHkSZ97+op7Leg3nD_=TFjJ1K3wSr3pWQbF4Eug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 May 2014 11:20:58 -0700
Cong Wang <cwang@twopensource.com> wrote:

> On Tue, May 13, 2014 at 8:39 AM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > There have been a couple of bugzilla reports already about cases where a macvlan
> > or vlan is moved into another namespace. In these cases the parent device ifindex (iflink)
> > is no longer valid.
> >
> >
> > Normally it is not a big issue, until another device is created using the ifindex
> > of the parent
> >
> > Does anyone have a suggested fix? Marking iflink as 0 won't work then the devices no
> > longer appear as slaves. Another possibility would be to make block creation of device
> > where ifindex matches existing iflink of other devices; but this would slow down device
> > creation.
> >
> 
> I have a pending fix which converts ->iflink to a pointer to struct net_device,
> this is a suggested fix from Ben. And so, when the lower device is not
> in the same
> namespace with the upper device, we should not display the iflink information.
> 
> I will send it soon.

That won't solve the problem.
 1. a pointer increase size of netns and requires refcount
 2. iflink is still exposed in kernel user API and has to be set
    otherwise the device is falsely reported.
