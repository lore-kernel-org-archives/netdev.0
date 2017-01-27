From: Florian Fainelli <f.fainelli@gmail.com>
Subject: cls_matchall and port mirroring questions
Date: Thu, 26 Jan 2017 19:00:50 -0800
Message-ID: <f310a430-cd20-f0b0-801c-49376ca20acb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33113 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753013AbdA0DBK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 22:01:10 -0500
Received: by mail-pf0-f196.google.com with SMTP id e4so17555724pfg.0
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 19:00:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

As I am adding support for cls_matchall in the b53/bcm_sf2 drivers, I
was looking into several, yet unrelated things:

- mlxsw does not seem to specify whether the port used for capture
remains usable, or blocks non-mirror traffic ingressing/egressing it, do
we want a control knob for that? If not, what is a sensible default,
block all non capture traffic?

- do we have an updated man page for tc-matchall.8 that features how to
use the statistical sampler too? b53 switches have a divider that allows
us to select how many frames we want to receive (10 bit value).

- b53 supports capture against a particular MAC SA or DA (or both), do
we want to be able to control that somehow? What about Marvell switches,
what can they do?

-  a fair amount of code dealing with the cls_matchall mirroring entry
is not switch driver specific, in fact, the only things that are switch
driver specific are:
	- list pointer where to store this entry (typically in the private
network device context)
	- operation to check whether the device belongs to us (identical
netdev_ops)
	- retrieval of the destination port number (to_port) which is also
typically available in network device private context

Do we want to move a fair amount of code into switchdev, treat
cls_matchall entries as a specific switchdev object, and have drivers
take over at the same level that mlxsw_sp_port_add_cls_matchall_mirror()
currently starts?

Thanks!
-- 
Florian
