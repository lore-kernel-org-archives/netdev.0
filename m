From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [Bug 1490] New: _decode_session[46] does not set type or code for ICMP or ICMPv6]
Date: Tue, 4 Nov 2003 20:31:19 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031104223118.GB23401@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

FYI

----- Forwarded message from bugme-daemon@osdl.org -----

Date: Tue, 4 Nov 2003 08:54:36 -0800
From: bugme-daemon@osdl.org
Subject: [Bug 1490] New: _decode_session[46] does not set type or code for ICMP or ICMPv6
To: acme@conectiva.com.br

http://bugme.osdl.org/show_bug.cgi?id=1490

           Summary: _decode_session[46] does not set type or code for ICMP
                    or ICMPv6
    Kernel Version: 2.6.0-test9
            Status: NEW
          Severity: normal
             Owner: acme@conectiva.com.br
         Submitter: bbuesker@qualcomm.com


Distribution: Redhat 9
Hardware Environment: x86
Software Environment: ipsec-tools-0.2.2
Problem Description:
The _decode_session[46] functions do not set the type and code for ICMP and
ICMPv6. These values need to be set so that policies can be matched based on
these fields, since setkey allows for specifying policies based on the type and
code. 
Furthermore, __xfrm[46]_selector_match do not correctly handle ICMP and ICMPv6.
The type should be compared against the xfrm_selector's sport field, and the
code should be compared against the dport field. The type and code are both 8
bit fields, whereas __xfrm[46]_selector_match is comparing 16 bit values.

Steps to reproduce:
Insert a policy into the SPD using setkey that requires IPsec protection. For
example, require inbound router advertisements to be protected with ESP with the
following:

spdadd ::/0 ::/0 icmp6 134,0 -P in ipsec esp/transport//require;

Then send a router advertisement to the system under test. The packet will not
be dropped, and the system will generate an IPv6 address.

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.

----- End forwarded message -----
