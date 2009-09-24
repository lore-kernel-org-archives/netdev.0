From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 5/4] Documentation: correction to isdn/INTERFACE.CAPI
Date: Fri, 25 Sep 2009 00:04:09 +0200 (CEST)
Message-ID: <20090924-patch-capi-5.tilman@imap.cc>
References: <20090924-patch-0.tilman@imap.cc>
Cc: davem@davemloft.net, i4ldeveloper@listserv.isdn4linux.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	Karsten Keil <keil@b1-systems.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:52281 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752371AbZIXWES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2009 18:04:18 -0400
In-Reply-To: <20090924-patch-0.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct the paragraphs describing the _cstruct and _cmstruct types.
The _cstruct representation is in fact used for some struct
parameters containing struct subparameters, too.

Impact: documentation
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 Documentation/isdn/INTERFACE.CAPI |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/Documentation/isdn/INTERFACE.CAPI b/Documentation/isdn/INTERFACE.CAPI
index e6bb1a7..5fe8de5 100644
--- a/Documentation/isdn/INTERFACE.CAPI
+++ b/Documentation/isdn/INTERFACE.CAPI
@@ -217,18 +217,19 @@ u16         for CAPI parameters of type 'word'
 
 u32         for CAPI parameters of type 'dword'
 
-_cstruct    for CAPI parameters of type 'struct' not containing any
-	    variably-sized (struct) subparameters (eg. 'Called Party Number')
+_cstruct    for CAPI parameters of type 'struct'
 	    The member is a pointer to a buffer containing the parameter in
 	    CAPI encoding (length + content). It may also be NULL, which will
 	    be taken to represent an empty (zero length) parameter.
+	    Subparameters are stored in encoded form within the content part.
 
-_cmstruct   for CAPI parameters of type 'struct' containing 'struct'
-	    subparameters ('Additional Info' and 'B Protocol')
+_cmstruct   alternative representation for CAPI parameters of type 'struct'
+	    (used only for the 'Additional Info' and 'B Protocol' parameters)
 	    The representation is a single byte containing one of the values:
-	    CAPI_DEFAULT: the parameter is empty
-	    CAPI_COMPOSE: the values of the subparameters are stored
-	    individually in the corresponding _cmsg structure members
+	    CAPI_DEFAULT: The parameter is empty/absent.
+	    CAPI_COMPOSE: The parameter is present.
+	    Subparameter values are stored individually in the corresponding
+	    _cmsg structure members.
 
 Functions capi_cmsg2message() and capi_message2cmsg() are provided to convert
 messages between their transport encoding described in the CAPI 2.0 standard
-- 
1.6.2.1.214.ge986c

