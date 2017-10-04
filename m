From: David Ahern <dsa@cumulusnetworks.com>
Subject: devlink dump of mlxsw_adj table triggers a panic
Date: Wed, 4 Oct 2017 16:57:35 -0700
Message-ID: <78e0bce8-e122-ab92-2f48-e9d278f4d2b4@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Arkadi Sharshevsky <arkadis@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:49796 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751132AbdJDX5h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 19:57:37 -0400
Received: by mail-pg0-f47.google.com with SMTP id v13so7356688pgq.6
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 16:57:37 -0700 (PDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following devlink command on a 2700 triggers a panic every time.
Kernel is net-next at 26873308b21654b6e0785b9f9e2c5414d37a4c4c

$ devlink  dpipe table dump pci/0000:03:00.0 name mlxsw_adj
devlink answers: No buffer space available
<hang>

I have seen several different stack traces and varying amounts of EMAD
errors on console:

[   77.453364] mlxsw_spectrum 0000:03:00.0: EMAD reg access failed
(tid=64c24a400003688,reg_id=200b(sfn),type=query,status=0(operation
performed))
[   77.466568] mlxsw_spectrum 0000:03:00.0: Failed to get FDB notifications

If it does not reproduce for you let me know and I'll grab a trace.

David
