From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 25/39] mv643xx_eth: massively simplify multicast address crc8 computation
Date: Thu, 5 Jun 2008 22:44:50 +0200
Message-ID: <20080605204450.GE30083@xi.wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-26-git-send-email-buytenh@wantstofly.org> <200806050908.56427.bcook@bpointsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org
To: Brent Cook <bcook@bpointsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:54940 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbYFEUpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 16:45:23 -0400
Content-Disposition: inline
In-Reply-To: <200806050908.56427.bcook@bpointsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 05, 2008 at 09:08:56AM -0500, Brent Cook wrote:

> > Replace the 70-line crc8 computation (used for multicast address
> > filtering tables) by a 5-line version.
> 
> The original looks like someone ported Verilog code to C.

E.g. the EASICS crc web tool (http://www.easics.com/webtools/crctool)
gives you pretty much that same code.  :-)

I.e.:

    NewCRC[0] = D[45] ^ D[43] ^ D[40] ^ D[39] ^ D[35] ^ D[34] ^ D[31] ^ 
                D[30] ^ D[28] ^ D[23] ^ D[21] ^ D[19] ^ D[18] ^ D[16] ^ 
                D[14] ^ D[12] ^ D[8] ^ D[7] ^ D[6] ^ D[0] ^ C[0] ^ 
                C[3] ^ C[5];
    NewCRC[1] = D[46] ^ D[45] ^ D[44] ^ D[43] ^ D[41] ^ D[39] ^ D[36] ^ 
                D[34] ^ D[32] ^ D[30] ^ D[29] ^ D[28] ^ D[24] ^ D[23] ^ 
                D[22] ^ D[21] ^ D[20] ^ D[18] ^ D[17] ^ D[16] ^ D[15] ^ 
                D[14] ^ D[13] ^ D[12] ^ D[9] ^ D[6] ^ D[1] ^ D[0] ^ 
                C[1] ^ C[3] ^ C[4] ^ C[5] ^ C[6];

versus mv643xx_eth's:

-       crc[0] = mac_array[45] ^ mac_array[43] ^ mac_array[40] ^ mac_array[39] ^
-                mac_array[35] ^ mac_array[34] ^ mac_array[31] ^ mac_array[30] ^
-                mac_array[28] ^ mac_array[23] ^ mac_array[21] ^ mac_array[19] ^
-                mac_array[18] ^ mac_array[16] ^ mac_array[14] ^ mac_array[12] ^
-                mac_array[8]  ^ mac_array[7]  ^ mac_array[6]  ^ mac_array[0];
-
-       crc[1] = mac_array[46] ^ mac_array[45] ^ mac_array[44] ^ mac_array[43] ^
-                mac_array[41] ^ mac_array[39] ^ mac_array[36] ^ mac_array[34] ^
-                mac_array[32] ^ mac_array[30] ^ mac_array[29] ^ mac_array[28] ^
-                mac_array[24] ^ mac_array[23] ^ mac_array[22] ^ mac_array[21] ^
-                mac_array[20] ^ mac_array[18] ^ mac_array[17] ^ mac_array[16] ^
-                mac_array[15] ^ mac_array[14] ^ mac_array[13] ^ mac_array[12] ^
-                mac_array[9]  ^ mac_array[6]  ^ mac_array[1]  ^ mac_array[0];
