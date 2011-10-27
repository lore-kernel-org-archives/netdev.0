From: =?ISO-8859-1?Q?David_T=E4ht?= <dave.taht@gmail.com>
Subject: adding nat awareness in routing daemons?
Date: Thu, 27 Oct 2011 09:04:31 +0200
Message-ID: <4EA9027F.7000702@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000706060206030302010200"
To: netdev@vger.kernel.org, bloat-devel@lists.bufferbloat.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37749 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889Ab1J0HEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 03:04:41 -0400
Received: by faan17 with SMTP id n17so2311355faa.19
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2011 00:04:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000706060206030302010200
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

after shooting myself in the foot on this several times in the past 
couple months, I thought I'd ask...

Is there a way to determine generically (in linux at least) if outgoing 
addresses on an interface are being NATTed or not? via netlink? I can 
come up with a way to do this via parsing iptables's nat table but 
that's kind of ugly.

The scenario I have is two (or more) routers with their external 
interfaces connected to a shared ethernet/cable segment. Both do NAT on 
their external interfaces for ipv4 (but don't do nat, at least 
currently, for ipv6). Their private networks are usually connected 
together via various means (mesh mostly), which can fail, and it would 
be nice to be able to add the external connectivity as a fallback 
without having to worry about NAT.

e.g. something like

if (nat_status(&this_interface)) {
         if(this_interface & IPV4_NO_NAT) send_route4_calculations();
         if(this_interface & IPV6_NO_NAT) send_route6_calculations();
}

Where I did myself in on this was in the lab

http://io.lab.bufferbloat.net:8080/


-- 
Dave Täht


--------------000706060206030302010200
Content-Type: text/x-vcard; charset=utf-8;
 name="dave_taht.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="dave_taht.vcf"

begin:vcard
fn;quoted-printable:Dave T=C3=A4ht
n;quoted-printable:T=C3=A4ht;Dave
email;internet:dave.taht@gmail.com
tel;home:1-239-829-5608
tel;cell:0638645374
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------000706060206030302010200--
