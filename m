From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: If bridge have no sub-interfaces, it's status may be still with
 'RUNNING'
Date: Fri, 13 Feb 2015 13:30:56 -0500
Message-ID: <20150213133056.3944c13e@uryu.home.lan>
References: <54DDCA99.4040401@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>
To: yzhu1 <Yanjun.Zhu@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:38292 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643AbbBMSbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 13:31:01 -0500
Received: by mail-pa0-f41.google.com with SMTP id kx10so20528942pab.0
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 10:31:01 -0800 (PST)
In-Reply-To: <54DDCA99.4040401@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Feb 2015 17:57:45 +0800
yzhu1 <Yanjun.Zhu@windriver.com> wrote:

> Hi, all
> 
> I made this test on ubuntu 14.04 with kernel 3,19-rc7:
> 
> 1. brctl addbr br0
> 
> 2. ifconfig br0 up
> 
> 3. ifconfig br0 (br0's status is with 'RUNNING')
> 
> 4. brctl addif br0 eth0
> 
> 5. brctl delif br0 eth0
> 
> 6. ifconfig br0 (br0's status is without 'RUNNING')
> 
> When there is no sub-interface, the flag "RUNNING" is missing after the 
> last sub-interface is removed.
> 
> As such, should we keep "RUNNING" flag after the last sub-interface is 
> removed?

This is intentional. If there are no active ports in bridge, then
we want to tell applications that packets will go nowhere.
