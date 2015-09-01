From: James Loosli <loosli@gmail.com>
Subject: Issue with /etc/netns/${nsname}/hosts
Date: Tue, 1 Sep 2015 16:23:39 -0700
Message-ID: <CA+pPspp_b+50Z6+VNr4Y4K2BguHJZ9ykKCZ8j3aaFRkBOrbZGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33003 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbbIAXYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 19:24:00 -0400
Received: by wicmc4 with SMTP id mc4so48592667wic.0
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 16:23:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I seem to have an issue with using namespace-specific hosts files.
Here's an example.

I have different entries for foo.com in my hosts file for the
namespace and the system-wide hosts file;

root@server-01 Tue Sep 01 04:15:02pm
> cat /etc/netns/nsXX-XXX-240-3/hosts | grep foo
1.2.3.4 foo.com
root@server-01 Tue Sep 01 04:15:15pm
> ip netns exec nsXX-XXX-240-3 cat /etc/hosts | grep foo
1.2.3.4 foo.com
root@server-01 Tue Sep 01 04:15:19pm
> cat /etc/hosts | grep foo
0.0.0.0 foo.com

But when I try to get curl, ping or other utilities to use that hosts
file entry, they ignore the namespace-specific file.

root@server-01 Tue Sep 01 04:16:02pm
> ip netns exec ns91-227-240-3 curl -vv foo.com
* About to connect() to foo.com port 80 (#0)
*   Trying 0.0.0.0...
* Connection refused
* couldn't connect to host
* Closing connection #0
curl: (7) couldn't connect to host
root@server-01 Tue Sep 01 04:16:08pm
> curl -vv foo.com
* About to connect() to foo.com port 80 (#0)
*   Trying 0.0.0.0...
* Connection refused
* couldn't connect to host
* Closing connection #0
curl: (7) couldn't connect to host

Not sure what I'm doing wrong, but this behavior seems to contradict
what I find in the manpages for iproute2 and netns /etc files. Could
this be permissions related?

Regards,

James Loosli
949.439.6109
loosli@gmail.com
