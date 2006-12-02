From: Kari Hurtta <hurtta+gmane@siilo.fmi.fi>
Subject: Re: Network virtualization/isolation
Date: 02 Dec 2006 13:29:02 +0200
Message-ID: <5dmz66sfi9.fsf@Hurtta06k.keh.iki.fi>
References: <453F8800.9070603@fr.ibm.com> <45408397.8070404@fr.ibm.com> <20061026085659.33b4c6dd@freekitty> <200610271134.56830.dim@openvz.org> <4541CCF4.4050306@fr.ibm.com> <1162391707.5251.78.camel@jzny2> <4559DE01.5090109@fr.ibm.com> <m1y7pzoptr.fsf@ebiederm.dsl.xmission.com> <456C447E.5090703@fr.ibm.com> <m1r6vnikeq.fsf@ebiederm.dsl.xmission.com> <456C9B8C.1010701@fr.ibm.com> <m14psji6lw.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:39104 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1423146AbWLBL3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Dec 2006 06:29:40 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1GqT3Y-00072k-DL
	for netdev@vger.kernel.org; Sat, 02 Dec 2006 12:29:20 +0100
Received: from cs181108174.pp.htv.fi ([82.181.108.174])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 02 Dec 2006 12:29:20 +0100
Received: from hurtta+gmane by cs181108174.pp.htv.fi with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 02 Dec 2006 12:29:20 +0100
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ebiederm@xmission.com (Eric W. Biederman) writes in gmane.linux.network:

> Ok.  So on this point we agree.  Full isolation at the network device/L2 level
> is desirable and no one is opposed to that.
> 
> There is however a strong feeling especially for the case of application
> containers that something more focused on what a non-privileged process can
> use and deal with would be nice.  The ``L3'' case.
> 
> I agree that has potential but I worry about 2 things.
> - Premature optimization.
> - A poor choice of semantics.
> - Feature creep leading to insane semantics.
> 
> I feel there is something in the L3 arguments as well and it sounds
> like it would be a good idea to flush out the semantics.
> 
> For full network isolation we have the case that every process,
> every socket, and every network device belongs to a network namespace.
> This is enough to derive the network namespace for all other user
> visible data structures, and to a large extent to define their semantics.
> 
> We still need a definition of the non-privileged case, that is compatible
> with the former definition.
> 
> .....
> 
> What unprivileged user space gets to manipulate are sockets.  So perhaps
> we can break our model into a network socket namespace and network device
> namespace.  
> 
> I would define it so that for each socket there is exactly one network
> socket namespace.  And for each network socket namespace there is exactly
> one network device namespace.
> 
> The network socket namespace would be concerned with the rules for deciding
> which local addresses a socket can connect/accept/bind to.
> 
> The network device namespace would be concerned with everything else.

There need decide one thing:  What is connection between  namespaces?

    - Connection between the network device namespaces is bridge.

    - What (socket) is connection between the network socket namespaces?

Connection inside on name namespace is clear I think.

     - Connection inside of network device namespaces is loopback device.

     - Connection inside of network socket namespaces is socket
       using loopback address(es)?

/ Kari Hurtta



