From: Thomas Egerer <thomas.egerer@secunet.com>
Subject: [PATCH iproute2 0/3] various patches for (socket) policies/states
Date: Mon, 30 Oct 2017 19:11:42 +0100
Message-ID: <e7856766-873d-5df0-a49a-dc9eaf9cce4c@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:58708 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751959AbdJ3SNG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 14:13:06 -0400
Received: from localhost (localhost [127.0.0.1])
        by a.mx.secunet.com (Postfix) with ESMTP id B60D6201D1
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 19:13:05 +0100 (CET)
Received: from a.mx.secunet.com ([127.0.0.1])
        by localhost (a.mx.secunet.com [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id 3P-9shX0ElkD for <netdev@vger.kernel.org>;
        Mon, 30 Oct 2017 19:13:05 +0100 (CET)
Received: from mail-essen-01.secunet.de (mail-essen-01.secunet.de [10.53.40.204])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by a.mx.secunet.com (Postfix) with ESMTPS id 3F9FF20078
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 19:13:05 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello *,

the following set of three patches tries deals with socket policies.
The first patch adresses the missing filter option for socket
polices. Especially when dealing with many of those, it is quite
cumbersome to filter them from the iproute2-output. So an option
to remove them from the output has been added.
Also when trying to deleteall policies iproute2 tries to delete
socket based policies, too. The result is an error message which
is misleading and unnecessary. So the second patch skips all
socket policies when deleteall-ing policies.
The third patch allow to deleteall policies and states even if
they have a mark. I'm not sure if the current behavior is
intended but if iproute2 finds a policy or state with a mark
it tries to delete the corresponding policy/state *without*
a mark. Also the result is an error and the policy/state is
not deleted.
All patches are rebased onto net-next.

Regards
Thomas

Thomas Egerer (3):
  xfrm_policy: Add filter option for socket policies
  xfrm_policy: Do not attempt to deleteall a socket policy
  xfrm_{state,policy}: Allow to deleteall polices/states with marks

 ip/xfrm.h        |  1 +
 ip/xfrm_policy.c | 21 ++++++++++++++++++++-
 ip/xfrm_state.c  | 12 ++++++++++++
 3 files changed, 33 insertions(+), 1 deletion(-)

-- 
2.6.4
