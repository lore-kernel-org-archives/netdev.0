From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] TCP: Add support for TCP Stealth
Date: Fri, 02 Jan 2015 13:50:56 +0100
Message-ID: <54A69430.2060800@redhat.com>
References: <54A470B3.3010501@sec.in.tum.de> <54A566F2.4070401@redhat.com> <54A56880.6040802@grothoff.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Julian Kirsch <kirschju@sec.in.tum.de>, netdev@vger.kernel.org,
	Jacob Appelbaum <jacob@appelbaum.net>,
	Pavel Emelyanov <xemul@parallels.com>
To: Christian Grothoff <christian@grothoff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39914 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750771AbbABMwT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jan 2015 07:52:19 -0500
In-Reply-To: <54A56880.6040802@grothoff.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/01/2015 04:32 PM, Christian Grothoff wrote:
...
> That approach is highly vulnerable to timing attacks, and doesn't answer
> how TCP clients without special capabilities could set the ISN correctly
> either. Playing with raw sockets is the kind of geeky hack that is

Right, for client/server side you'd need to have the capabilities and
then drop them later, which would make that approach less convenient
for user space applications (despite not having to have a port knocking
uapi in the TCP core itself). For the server, you might get away with a
central daemon spawning sockets via IPC, but for the unprivileged
client to e.g., let it set it's own ISN via setsockopt(2) would be a
bad idea.

> unlikely to give us the combination of usability and security required
> to significantly reduce the ongoing large-scale compromise of network
> equipment by spy agencies.

Out of curiosity, when you say you want to significantly reduce the
large-scale compromise of services by hiding ports, how do you solve
i) the pre-shared key distribution issue you need for your approach
(are you mostly targeting administrators for accessing their companies
router/firewall management interfaces?), and ii) the broad adoption of
this setsockopt(2) in applications? I think for ii) it would be great
not having to change and recompile every possible client _and_ server
application if they don't have the change upstreamed in their project.
It feels like a property that goes beyond the scope of a specific,
individual application, put differently, what about an additional
central configuration interface? Other than that, is there a plan for
key rotations in other words, to have a grace period for a key
transition as peers might not have synced clocks?
