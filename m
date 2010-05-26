From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Thu, 27 May 2010 01:15:12 +0200
Message-ID: <20100526231512.GD2684@nuttenaction>
References: <87fx1e1sat.fsf@basil.nowhere.org>
 <20100526.140818.245406045.davem@davemloft.net>
 <20100526212745.GC24615@basil.fritz.box>
 <20100526.151014.70204145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:57298 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757409Ab0EZXPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 19:15:15 -0400
Content-Disposition: inline
In-Reply-To: <20100526.151014.70204145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller | 2010-05-26 15:10:14 [-0700]:

>From: Andi Kleen <andi@firstfloor.org>
>Date: Wed, 26 May 2010 23:27:45 +0200
>
>> As I understand the idea was that the application knows
>> what flows belong to a single peer and wants to have
>> a single cwnd for all of those. Perhaps there would
>> be a way to generalize that to tell it to the kernel.
>> 
>> e.g. have a "peer id"  that is known by applications
>> and the kernel could manage cwnds shared between connections
>> associated with the same peer id?
>> 
>> Just an idea, I admit I haven't thought very deeply
>> about this. Feel free to poke holes into it.
>
>Yes, a CWND "domain" that can include multiple sockets is
>something that might gain some traction.
>
>The "domain" could just simply be the tuple {process,peer-IP}

This discussion - as once a month - is about fairness. But if we define a
domain as a tuple of {process,peer-IP} the fairness is applied only for the
last link before "peer-IP".

But fairness applies to *all* links in between! For example: consider a
dumpbell scenario:


+------+                                   +------+ 
|      |                                   |      |  
|  H1  |                                   |  H3  | 
|      |                                   |      |  
+------+                                   +------+  
  10MB  \   +------+            +------+  / 10MB
         \  |      |   1MB/s    |      | / 
          > |  R1  |------------|  R2  |<    
         /  |      |            |      | \      
  10MB  /   +------+            +------+  \ 10MB 
+------+                                   +------+  
|      |                                   |      |        
|  H2  |                                   |  H4  | 
|      |                                   |      | 
+------+                                   +------+


How can a domain defined as {process,peer-IP} fair to the 1MB bottleneck link?
It is not fair! And it is also not fair to open n simultaneous streams and so
on. This problem is discussed in several RFC's.

.02


Best regards, Hagen


-- 
Hagen Paul Pfeifer <hagen@jauu.net>  ||  http://jauu.net/
Telephone: +49 174 5455209           ||  Key Id: 0x98350C22
Key Fingerprint: 490F 557B 6C48 6D7E 5706 2EA2 4A22 8D45 9835 0C22

