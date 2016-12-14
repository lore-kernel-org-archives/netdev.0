From: "Du, Fan" <fan.du@intel.com>
Subject: [Query] Delayed vxlan socket creation?
Date: Wed, 14 Dec 2016 07:49:24 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF06788481A9457F1@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "mrjana@gmail.com" <mrjana@gmail.com>, "Du, Fan" <fan.du@intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36898 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754744AbcLNHw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Dec 2016 02:52:56 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I'm interested to one Docker issue[1] which looks like related to kernel vxlan socket creation
as described in the thread. From my limited knowledge here, socket creation is synchronous ,
and after the *socket* syscall, the sock handle will be valid and ready to linkup.

Somehow I'm not sure the detailed scenario here, and which/how possible commit fix?
Thanks!

Quoted analysis:
--------------------------------------------------------------------------
(Found in kernel 3.13)
The issue happens because in older kernels when a vxlan interface is created, 
the socket creation is queued up in a worker thread which actually creates 
the socket. But this needs to happen before we bring up the link on the vxlan interface. 
If for some chance, the worker thread hasn't completed the creation of the socket 
before we did link up then when we do link up the kernel checks if the socket was 
created and if not it will return ENOTCONN. This was a bug in the kernel which got fixed
in later kernels. That is why retrying with a timer fixes the issue.

[1]: https://github.com/docker/libnetwork/issues/1247
