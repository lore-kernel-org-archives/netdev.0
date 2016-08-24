From: Rick Jones <rick.jones2@hpe.com>
Subject: A second case of XPS considerably reducing single-stream performance
Date: Wed, 24 Aug 2016 08:52:18 -0700
Message-ID: <549357ea-dfda-284b-cdd6-4408060f9ca8@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
        sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hpe.com ([15.241.32.99]:17535 "EHLO
        g9t1613g.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755413AbcHXPwV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 11:52:21 -0400
Received: from g4t3427.houston.hpe.com (g4t3427.houston.hpe.com [15.241.140.73])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g9t1613g.houston.hpe.com (Postfix) with ESMTPS id C327762478
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 15:52:20 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Back in February of this year, I reported some performance issues with 
the ixgbe driver enabling XPS by default and instance network 
performance in OpenStack:

http://www.spinics.net/lists/netdev/msg362915.html

I've now seen the same thing with be2net and Skyhawk.  In this case, the 
magnitude of the delta is even greater.  Disabling XPS increased the 
netperf single-stream performance out of the instance from an average of 
4108 Mbit/s to 8888 Mbit/s or 116%.

Should drivers really be enabling XPS by default?

		      Instance To Outside World
			Single-stream netperf
		    ~30 Samples for Each Statistic
                               Mbit/s

                  Skyhawk            BE3 #1            BE3 #2
              XPS On   XPS Off  XPS On   XPS Off  XPS On   XPS Off
Median        4192     8883     8930     8853     8917     8695
Average       4108     8888     8940     8859     8885     8671

happy benchmarking,

rick jones

The sample counts below may not fully support the additional statistics 
but for the curious:

raj@tardy:/tmp$ ~/netperf2_trunk/doc/examples/parse_single_stream.py -r 
6 waxon_performance.log  -f 2
Field2,Min,P10,Median,Average,P90,P99,Max,Count
be3-1,8758.850,8811.600,8930.900,8940.555,9096.470,9175.839,9183.690,31
be3-2,8588.450,8736.967,8917.075,8885.322,9017.914,9075.735,9094.620,32
skyhawk,3326.760,3536.008,4192.780,4108.513,4651.164,4723.322,4724.320,27
0 too-short lines ignored.
raj@tardy:/tmp$ ~/netperf2_trunk/doc/examples/parse_single_stream.py -r 
6 waxoff_performance.log  -f 2
Field2,Min,P10,Median,Average,P90,P99,Max,Count
be3-1,8461.080,8634.690,8853.260,8859.870,9064.480,9247.770,9253.050,31
be3-2,7519.130,8368.564,8695.140,8671.241,9068.588,9200.719,9241.500,27
skyhawk,8071.180,8651.587,8883.340,8888.411,9135.603,9141.229,9142.010,32
0 too-short lines ignored.

"waxon" is with XPS enabled, "waxoff" is with XPS disabled.  The servers 
are the same models/config as in February.

stack@np-cp1-comp0013-mgmt:~$ sudo ethtool -i hed3
driver: be2net
version: 10.6.0.3
firmware-version: 10.7.110.45
