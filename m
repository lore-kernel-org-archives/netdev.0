From: christophe.varoqui@free.fr
Subject: TCP RST problem
Date: Wed, 30 Jun 2004 12:27:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1088591247.40e2958f5d8d3@imp3-q.free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I got a strange problem :

A weblogic app reply to a POST request by a 302 redirect. As soon as the "302"
fragments are sent, the server emits a TCP RST. The client is then unable to do
its consecutive GET ordered by the redirect : it shows a "404".

Facts :

This behaviour is reproductible on vanilla lk 2.4.26, latest redhat EL kernel
and various Linux distros.

This behaviour is not reproductible with Windows NT/XP weblogic servers and
Tru64 servers.

This behaviour shows only when using Internet Explorer at the client side :
relyably with IE5, IE5.1, IE5.5 and less relyably with IE6. Mozilla browsers
don't ever trigger the RST. Latest IE Service Packs seem to solve the problem
too, but I don't have the leasure to force the upgrade on a *really* big client
park (+4000 PC).

Masking the Weblogic server behind a proxy or a LVS load-balancer mostly solve
the issue : RST get triggered less than 1 hit out of 50.

Droping the outgoing RST packets on the weblogic server fixes the problem 100%,
but may induce other problems.

Questions :

Does anyone have insights to share about how to solve the problem "cleanly" on
the server side, or simply an explanation of the phenomenon ?

What perturbations can I expect from filtering the outgoing RST on these
servers, given they will take hits from slow WAN clients ?

regards,
cvaroqui
-- 
