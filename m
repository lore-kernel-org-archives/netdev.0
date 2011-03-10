From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Subject: Re: Stale entries in RT_TABLE_LOCAL
Date: Thu, 10 Mar 2011 14:41:56 -0500
Message-ID: <201103101441.57105.alexandre.sidorenko@hp.com>
References: <201102231243.23579.alexandre.sidorenko@hp.com> <alpine.LFD.2.00.1103100139510.2372@ja.ssi.bg> <alpine.LFD.2.00.1103100222080.2550@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:6720 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753888Ab1CJTmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 14:42:08 -0500
In-Reply-To: <alpine.LFD.2.00.1103100222080.2550@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On March 9, 2011 08:50:27 PM Julian Anastasov wrote:
>         Aha, it seems the problem happens when the
> both lines are executed while there is another address on
> device and the last added address becomes secondary
> for the 1st, eg:

Hi Julian,

this is correct - you need another address on device. I used iptest.sh script 
for testing as it is easier and less error-prone than adding addresses 
manually. In additon, it reinserts 'dummy' module so that every time we start 
with a clean slate.

>         Alex, what is the kernel version and can you test
> 
> it on different kernels?

I tested this on SLES10 (2.6.16 kernel), RHEL5 (2.6.18 kernel) and 
Ubuntu/Maverick (2.6.35 kernel)

> 
> IP1: 192.168.140.31/22, primary
> IP2: 192.168.142.109/23, primary
> IP3: 192.168.142.109/22, secondary for primary IP1
> 
>         It is the route for IP3 that is leaked, with prefsrc=IP1.
> We create local route for secondary IPs with prefsrc=ItsPrimaryIP.
> Both local routes for 109 differ in prefsrc (fa_info). But on
> deletion only one route is deleted due to last_ip check - the first
> because on deletion prefsrc is not matched, fib_table_delete
> does not work in symmetric way. So, the local route created
> for IP3 remains no matter the deletion order.
> If we decide to create one unique local route for this case,
> there is a risk device unregistration to remove
> it (fib_sync_down_dev with force > 0). 

Yes, but do we _really_ need to be able to add the same IP multiple times 
(with different masks)? If not, we can just return an error when someine tries 
to add the same IP again with different mask.

Regards,
Alex

-- 
------------------------------------------------------------------
Alexandre Sidorenko             email: asid@hp.com
WTEC Linux			Hewlett-Packard (Canada)
------------------------------------------------------------------
