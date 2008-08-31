From: "Dushan Tcholich" <dusanc@gmail.com>
Subject: Re: ksoftirqd high cpu load on kernels 2.6.24 to 2.6.27-rc1-mm1
Date: Sun, 31 Aug 2008 21:14:50 +0200
Message-ID: <a08621850808311214j6a9ca210j8141164e50bc0f74@mail.gmail.com>
References: <fa.wTMiBcGRgw2fBtdHwtX7y0lkc8s@ifi.uio.no>
	 <48975BD3.6040709@shaw.ca>
	 <a08621850808041337k1d1deb6fk78098d9fcd4930dd@mail.gmail.com>
	 <20080807185802.GA16327@electric-eye.fr.zoreil.com>
	 <a08621850808101200n220afd2dve58abe67830b7a4f@mail.gmail.com>
	 <a08621850808110053j5cbf23e6xdf52c9e7440abf19@mail.gmail.com>
	 <a08621850808291848q5660148fx57d576ecfcbfce8@mail.gmail.com>
	 <a08621850808310151o143845h195a8658d02270d9@mail.gmail.com>
	 <20080831100537.6929c51e@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Francois Romieu" <romieu@fr.zoreil.com>,
	"Robert Hancock" <hancockr@shaw.ca>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:6553 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755895AbYHaTOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2008 15:14:51 -0400
Received: by wa-out-1112.google.com with SMTP id j37so1104400waf.23
        for <netdev@vger.kernel.org>; Sun, 31 Aug 2008 12:14:50 -0700 (PDT)
In-Reply-To: <20080831100537.6929c51e@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Sun, Aug 31, 2008 at 7:05 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Sun, 31 Aug 2008 10:51:46 +0200
> "Dushan Tcholich" <dusanc@gmail.com> wrote:
>
>> Hello
>> I found the culprit.
>>
>> When using powertop I get:
>> Top causes for wakeups:
>>   35,2% (251,0)                ip : br_stp_enable_bridge (br_hello_timer_expired
>>
>> So I tried to turn them off with:
>> brctl sethello br0 0
>> but the problem persisted.
>
>
> You can't turn off the hello timer, it is needed for Spanning Tree to
> work. The kernel should reject requests to set hello timer < 1sec.
> Most routers allow 1 - 10sec.
>
> I am going to do a new patch to add tighter range checking for STP timer
> settings and another to default fowarding delay of zero if STP is disabled.
>
Well I try to turn stp off but it doesn't  want to :)
This is in my /etc/conf.d/net
brctl_br0=( "setfd 0" "sethello 10" "stp off" )
I had problems with sethello 0 so now I'm using 10.
Tried with
brctl stp br0 off
but still had same troubles.

Have a nice day
Dushan
