From: Patrick McLean <patrick@cim.mcgill.ca>
Subject: [Bug #16572][REGRESSION, bisected] random panics in bridging on 2.6.34+
Date: Thu, 19 Aug 2010 14:55:26 -0400
Message-ID: <4C6D7E1E.4020207@cim.mcgill.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Jan Binder <jan@cim.mcgill.ca>
To: bridge@lists.linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am getting random panics with KVM/bridging on 2.6.34+ (including
latest git as of this morning).

There is a screenshot of the panic message in bugzilla at
https://bugzilla.kernel.org/show_bug.cgi?id=16572

It seems to happen when I have KVM virtual machines running with
bridging mode, most often when any of the virtual machines talk to the
network, or sometimes when they are brought up or down.

I bisected it down to this commit:

commit 68b7c895be336b19f4c38d7cb500132fabba0afd
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Sat Feb 27 19:41:40 2010 +0000

    bridge: Allow tail-call on br_pass_frame_up

    This patch allows tail-call on the call to br_pass_frame_up
    in br_handle_frame_finish.  This is now possible because of the
    previous patch to call br_pass_frame_up last.

    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>
