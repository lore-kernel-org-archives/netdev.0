From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: /proc/net/sockstat invalid memory accounting or memory leak in
 latest kernels?
Date: Thu, 17 Jul 2014 15:42:48 +0200
Message-ID: <1405604568.10255.80.camel@edumazet-glaptop2.roam.corp.google.com>
References: <40bc2b5fcda47d790f1fd247bc409041@visp.net.lb>
	 <1405597918.10255.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <37e25a5815a18a2da507a5b20b58427d@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:64586 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932179AbaGQNmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 09:42:53 -0400
Received: by mail-we0-f177.google.com with SMTP id w62so3052781wes.22
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 06:42:52 -0700 (PDT)
In-Reply-To: <37e25a5815a18a2da507a5b20b58427d@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-17 at 16:12 +0300, Denys Fedoryshchenko wrote:
> Well, it seems not normal. But i am not sure, is mem value means this 
> memory is allocated and not released?

mem means : sockets have forward_alloc reservations. They can use this
amount of memory without worrying.

> If it is allocated pages, MemFree in /proc/memstat should be different 
> value.

Its not allocated pages.

> I just shut down balancer process now and bypassed all traffic, and 
> waited all(ok, almost all) sockets to close, this particular server had 
> 300k connections before test.
> 
> sockets: used 78
> TCP: inuse 22 orphan 17 tw 2 alloc 22 mem 1048593
> UDP: inuse 1 mem 0
> UDPLITE: inuse 0
> RAW: inuse 0
> FRAG: inuse 0 memory 0
> 
> MemTotal:       32664776 kB
> MemFree:        32462456 kB
> MemAvailable:   32449704 kB
> 
> ss output:
> 
> Netid State      Recv-Q Send-Q                                           
>                                                            Local 
> Address:Port                                                             
>                                            Peer Address:Port
> nl    UNCONN     0      0                                                
>                                                                        
> 0:0                                                                      
>                                                  *
> nl    UNCONN     0      0                                                
>                                                                        
> 4:0                                                                      
>                                                  *
> nl    UNCONN     0      0                                                
>                                                                       
> 10:0                                                                     
>                                                   *
> nl    UNCONN     0      0                                                
>                                                                       
> 11:0                                                                     
>                                                   *
> nl    UNCONN     0      0                                                
>                                                                       
> 15:0                                                                     
>                                                   *
> nl    UNCONN     0      0                                                
>                                                                       
> 16:0                                                                     
>                                                   *
> nl    UNCONN     0      0                                                
>                                                                       
> 18:0                                                                     
>                                                   *
> nl    UNCONN     0      0                                                
>                                                                       
> 21:0                                                                     
>                                                   *
> tcp   UNCONN     0      0                                                
>                                                                        
> *:49484                                                                  
>                                                 *:*
>           skmem:(r0,rb2304,t0,tb212992,f0,w0,o0,bl0)
> tcp   LISTEN     0      1280                                             
>                                                                        
> *:8880                                                                   
>                                                 *:*
>           skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
> tcp   LISTEN     0      20                                               
>                                                                        
> *:22                                                                     
>                                                 *:*
>           skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
> tcp   LISTEN     0      1                                                
>                                                                        
> *:23                                                                     
>                                                 *:*
>           skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
> tcp   LISTEN     0      1280                                             
>                                                                        
> *:443                                                                    
>                                                 *:*
>           skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
> tcp   FIN-WAIT-1 0      4545                                             
>                                                            
> 157.56.194.74:443                                                        
>                                                   172.17.37.4:52473
>           skmem:(r0,rb8192,t0,tb8192,f3072,w9216,o0,bl0)
> tcp   ESTAB      0      3008                                             
>                                                               
> 10.0.22.22:22                                                            
>                                             194.146.153.22:59156
>           skmem:(r0,rb359040,t0,tb18432,f768,w11520,o0,bl0)
> tcp   FIN-WAIT-1 0      1                                                
>                                                           
> 54.225.250.234:443                                                       
>                                                  172.17.32.251:35969
>           skmem:(r0,rb8192,t0,tb8192,f2816,w1280,o0,bl0)
> tcp   FIN-WAIT-2 0      0                                                
>                                                           
> 206.53.159.203:443                                                       
>                                                   172.17.76.10:54688
> 
> tcp   FIN-WAIT-2 0      0                                                
>                                                            
> 173.194.39.40:443                                                        
>                                                 172.17.64.221:39482
> 
> tcp   FIN-WAIT-1 0      1                                                
>                                                            
> 69.171.235.48:443                                                        
>                                                 172.17.32.251:52731
>           skmem:(r0,rb8192,t0,tb8192,f4294966016,w1280,o0,bl0)

This looks bad : 

f4294966016 : 0xFFFFFB00

There is a bug of some sort, that leads to overflows.
