From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
	available to userspace
Date: Wed, 18 Jun 2008 10:40:44 +0100
Message-ID: <20080618094044.GD23684@gerrit.erg.abdn.ac.uk>
References: <20080517155916.34622BD22@poczta.oswiecenia.net> <200806150158.28488.tomasz@grobelny.oswiecenia.net> <20080617111638.GA14409@gerrit.erg.abdn.ac.uk> <200806172228.06801.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:35972 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752015AbYFRJlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 05:41:20 -0400
Content-Disposition: inline
In-Reply-To: <200806172228.06801.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > In the kernel I think it is best to make it type-safe, i.e. no new
| > parameters to already-defined policies. But I can't see how this would
| > restrict the use.
| > (...)
| >
| So we would need new policy for each new parameter, right? I somehow don't 
| like it but it should work. You are right that this way runtime parameter 
| discovery is not necessary. BTW, we will have a bit of a problem with naming 
| qpolicies ;-)
| 
Yes, not claiming that my suggestions were very good.

By the way, did you notice that the matrix was incomplete - timeout standalone
was missing, the corrected version would look something like

    +-------------+--------+-------------------+------------------+
    | Policy Name | Policy |         Presence of Parameters       |
    |             | ID#    | DCCP_SCM_PRIORITY | DCCP_SCM_TIMEOUT |
    +-------------+--------+-------------------+------------------+
    | "simple     |   0    |        no         |        no        |
    | "prio"      |   1    |       YES         |        no        |
    | "timeout"   |   2?   |        no         |       YES        |
    | "timed-prio"|   3?   |       YES         |       YES        |
    +-------------+--------+-------------------+------------------+

There is a special trick for the aggregate "timed-prio" policy: it is
the logical-OR of the "prio" and "timeout" policy IDs. Perhaps composite
policy IDs could be defined in this way.


| I will for sure be working on some apps to demonstrate how the new interface 
| can be used. But first I need to create a simple server/client transmitting 
| G.726 encoded voice over UDP/RTP (any hints on that?)...
| 
Tommi Saviranta has been working on a DCCP port for SpeexComm:
	http://tuomas.kulve.fi/projects/speexcomm/
The port is available via SVN:
	svn co http://tuomas.kulve.fi/svn/speexcomm

Leandro Sales de Melo has developed a DCCP plugin for gstreamer and used
it with VoIP/speex. It comes with example applications for these:
https://garage.maemo.org/frs/?group_id=297
https://garage.maemo.org/projects/ephone
http://www.mail-archive.com/dccp@vger.kernel.org/msg03101.html

