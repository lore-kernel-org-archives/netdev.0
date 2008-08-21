From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v3 00/13] Labeled networking patches for 2.6.28
Date: Thu, 21 Aug 2008 17:25:40 -0400
Message-ID: <20080821210239.7951.59652.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:6983 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbYHUVZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 17:25:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another update to the labeled networking patches for 2.6.28.  This revision
adds some small fixes, the dead-code removal patch posted earlier, and the big
addition ... wait for it ... full LSM label/context support for local
connections.  This is accomplished by creating a new, private CIPSO tag type
(allowed by the spec with a tag number > 127) which carries the LSM's secid
value, allowing full LSM contexts to be carried across local connections
without the headaches of labeled IPsec.

For those of you interested in testing this out, you will need the latest
from the netlabel_tools addrsel branch, revision 74 or higher should work.
If you enable the new local labeling you will almost certainly need to run
SELinux in permissive mode since I'm fairly certain the current policies don't
have the necessary allow rules.  With that said, enabling the new local
labeling is pretty easy ...

1. Add a CIPSO DOI which uses the new local labeling tag type, note you do
   not have to specify the tags

 # netlabelctl cipsov4 add local doi:2
 # netlabelctl -p cipsov4 list

2. Setup the default mapping to use the CIPSO DOI we just created for
   localhost, keeping in mind we have to remove the existing mapping first.
   Of course you don't have to use the default mapping, you can create your
   own domain specific mappings.

 # netlabelctl map del default
 # netlabelctl -p map list
 # netlabelctl map add default address:0.0.0.0/0 protocol:unlbl
 # netlabelctl map add default address:127.0.0.1 protocol:cipsov4,2
 # netlabelctl -p map list

3. Enjoy!

This should be the last bit of functionality for 2.6.28, the one possible
exception being a small patch to expose the static/fallback labeling mechanism
to Smack via the NetLabel KAPI.  Casey is still working on the Smack
portion of that effort and I'll only submit the NetLabel side once Smack is
ready for it.  Assuming no major problems are uncovered in the next week I'll
probably add the missing sign-offs and submit this to the linux-next tree for
further exposure and testing.

Thanks.

-- 
paul moore
linux @ hp
