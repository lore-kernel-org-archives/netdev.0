From: Chris Snook <csnook@redhat.com>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 09 Sep 2008 02:28:37 -0400
Message-ID: <48C61795.70806@redhat.com>
References: <48C59F75.6030504@redhat.com> <48C5A9A9.9040503@hp.com> <48C6052D.2080203@redhat.com> <20080908.221742.02572583.davem@davemloft.net> <48C60FFC.8090109@redhat.com> <20080909062208.GB30385@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58705 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753647AbYIIGbf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 02:31:35 -0400
In-Reply-To: <20080909062208.GB30385@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov wrote:
> Hi.
> 
> On Tue, Sep 09, 2008 at 01:56:12AM -0400, Chris Snook (csnook@redhat.com) wrote:
>> The easiest way to see the problem is to open a TCP socket to an echo 
>> daemon on loopback, make a bunch of small writes totaling less than your 
>> loopback MTU (accounting for overhead), and see how long it takes to get 
>> your echoes.  You can probably do this with netcat, though I haven't 
>> tried.  People don't expect loopback to have 40 ms latency when the box 
>> is lightly loaded, so they'd really like to tweak that down when it's 
>> hurting them.
> 
> Isn't Nagle without corking a very bad idea? Or you can not change the
> application?
> 

Yes, it is a bad idea.  We want to make the corking tunable, so people 
don't disable it completely to avoid these 40 ms latencies.  Also, we 
often can't change the application, so tuning this system-wide would be 
nice, and would be a lot less dangerous than turning on TCP_NODELAY 
system-wide the way people often do with solaris.

-- Chris
