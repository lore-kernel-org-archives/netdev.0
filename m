From: Daniel.Hopf@continental-corporation.com
Subject: ip -s macsec show: Statistics for OutOctets... and OutPkts... switched
Date: Mon, 21 Nov 2016 12:31:50 +0100
Message-ID: <OF4B44CECE.BF9C7A12-ONC1258072.0037C56C-C1258072.003F5731@continental-corporation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout03.rmx.de ([217.111.120.11]:54658 "EHLO mailout03.rmx.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754185AbcKULli (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 06:41:38 -0500
Received: from kdin02.retarus.de (kdin02.dmz1.retloc [172.19.17.49])
        (using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mailout03.rmx.de (Postfix) with ESMTPS id 3tMmf32YCqzlYrt
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 12:31:55 +0100 (CET)
Received: from FRHB102.fr.ge.conti.de ([10.220.1.13])
        by kdin02.retarus.de (8.15.2/8.14.5/retarus.custom) with ESMTPS id uALBVsmn005264
        (version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 12:31:54 +0100
Received: from frhb102.fr.ge.conti.de (FRHB102.fr.ge.conti.de [172.29.14.41])
        by FRHB102.fr.ge.conti.de (8.14.4/8.14.4) with ESMTP id uALBVr3N050244
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 12:31:54 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear community,

I'm using the following ip utility:

ubuntu2@ubuntu2:~$ ip -V
ip utility, iproute2-ss161009
ubuntu2@ubuntu2:~$ uname -r
4.8.0-22-generic

During tests with the recent MACsec implementation I noticed that the 
statistics for OutOctets[Protected|Encrypted] and 
OutPkts[Protected|Encrypted] are switched.

The error seems to reside in lines 637:640 of iproute2/ip/ipmacsec.c:
        [MACSEC_TXSC_STATS_ATTR_OUT_PKTS_PROTECTED] = 
"OutOctetsProtected",
        [MACSEC_TXSC_STATS_ATTR_OUT_PKTS_ENCRYPTED] = 
"OutOctetsEncrypted",
        [MACSEC_TXSC_STATS_ATTR_OUT_OCTETS_PROTECTED] = 
"OutPktsProtected",
        [MACSEC_TXSC_STATS_ATTR_OUT_OCTETS_ENCRYPTED] = 
"OutPktsEncrypted",

In my opinion this should instead read:
        [MACSEC_TXSC_STATS_ATTR_OUT_PKTS_PROTECTED] = "OutPktsProtected",
        [MACSEC_TXSC_STATS_ATTR_OUT_PKTS_ENCRYPTED] = "OutPktsEncrypted",
        [MACSEC_TXSC_STATS_ATTR_OUT_OCTETS_PROTECTED] = 
"OutOctetsProtected",
        [MACSEC_TXSC_STATS_ATTR_OUT_OCTETS_ENCRYPTED] = 
"OutOctetsEncrypted",

Regards
- Daniel
