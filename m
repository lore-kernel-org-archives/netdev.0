From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Fri, 16 Sep 2016 22:00:00 +0300
Message-ID: <20160916190000.GA18116@uranus.lan>
References: <20160913171950.GC32643@uranus>
 <8260ff1f-6907-aed8-caae-68d63a4ad529@cumulusnetworks.com>
 <20160915202219.GB1867@uranus.lan>
 <f482796f-185e-a3b7-248c-20f1f39cb459@cumulusnetworks.com>
 <20160915210126.GC1867@uranus.lan>
 <1473979691.22679.55.camel@edumazet-glaptop3.roam.corp.google.com>
 <999f0ddb-82e4-ea07-b52a-59d08bc7816d@cumulusnetworks.com>
 <20160916070623.GD1867@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        avagin@openvz.org, stephen@networkplumber.org
To: David Ahern <dsa@cumulusnetworks.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33829 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752035AbcIPTAD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 15:00:03 -0400
Content-Disposition: inline
In-Reply-To: <20160916070623.GD1867@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 16, 2016 at 10:06:23AM +0300, Cyrill Gorcunov wrote:
> On Thu, Sep 15, 2016 at 05:45:02PM -0600, David Ahern wrote:
> > > 
> > > Try to be selective in the -K , do not kill tcp sockets ?
> > 
> > I am running
> >    ss -aKw 'dev == red'
> > 
> > to kill raw sockets bound to device named 'red'.
> 
> Thanks David, Eric! I'll play with this option today and report the results.

I created veth pair and bound raw socket into it.

[root@pcs7 iproute2]# misc/ss -A raw
State      Recv-Q Send-Q                                Local Address:Port                                                 Peer Address:Port                
ESTAB      0      0                                         127.0.0.1:ipproto-255                                            127.0.0.10:ipproto-9090         
UNCONN     0      0                                        127.0.0.10:ipproto-255                                                     *:*                    
UNCONN     0      0                                                :::ipv6-icmp                                                      :::*                    
UNCONN     0      0                                                :::ipv6-icmp                                                      :::*                    
ESTAB      0      0                                               ::1:ipproto-255                                                   ::1:ipproto-9091         
UNCONN     0      0                                           ::1%vm1:ipproto-255                                                    :::*                    
[root@pcs7 iproute2]# 

[root@pcs7 iproute2]# misc/ss -aKw 'dev == vm1'
State      Recv-Q Send-Q                                Local Address:Port                                                 Peer Address:Port                
UNCONN     0      0                                           ::1%vm1:ipproto-255                                                    :::*                    

[root@pcs7 iproute2]# misc/ss -A raw
State      Recv-Q Send-Q                                Local Address:Port                                                 Peer Address:Port                
ESTAB      0      0                                         127.0.0.1:ipproto-255                                            127.0.0.10:ipproto-9090         
UNCONN     0      0                                        127.0.0.10:ipproto-255                                                     *:*                    
UNCONN     0      0                                                :::ipv6-icmp                                                      :::*                    
UNCONN     0      0                                                :::ipv6-icmp                                                      :::*                    
ESTAB      0      0                                               ::1:ipproto-255                                                   ::1:ipproto-9091         

so it get zapped out. Is there some other way to test it?
