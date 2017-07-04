From: Lucas Bates <lucasb@mojatatu.com>
Subject: [PATCH iproute2 1/1] Add new man page for tc actions.
Date: Tue,  4 Jul 2017 17:40:35 -0400
Message-ID: <1499204435-29331-1-git-send-email-lucasb@mojatatu.com>
Cc: netdev@vger.kernel.org, jiri@resnulli.us, psutter@redhat.com,
        jbenc@redhat.com, Lucas Bates <lucasb@mojatatu.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:35553 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752169AbdGDVl0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 17:41:26 -0400
Received: by mail-it0-f51.google.com with SMTP id v202so105472611itb.0
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2017 14:41:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This page is to highlight all operations and options that are
applicable to all tc actions.

Signed-off-by: Lucas Bates <lucasb@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 man/man8/tc-actions.8 | 221 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 221 insertions(+)
 create mode 100644 man/man8/tc-actions.8

diff --git a/man/man8/tc-actions.8 b/man/man8/tc-actions.8
new file mode 100644
index 0000000..51f43af
--- /dev/null
+++ b/man/man8/tc-actions.8
@@ -0,0 +1,221 @@
+.TH "actions in tc" 8 "4 Jul 2017" "iproute2" "Linux"
+
+.SH NAME
+actions \- independently defined actions in tc
+.SH SYNOPSIS
+.B tc
+[
+.I TC_OPTIONS
+]
+.B actions
+.BR add " | " change " | " replace
+.I ACTSPEC
+
+.B tc
+[
+.I TC_OPTIONS
+]
+.B actions
+.BR get " | " delete
+.I ACTISPEC
+
+.B tc
+[
+.I TC_OPTIONS
+]
+.B actions flush
+.I ACTNAMESPEC
+
+.B tc
+[
+.I TC_OPTIONS
+]
+.B actions
+.BR ls " | " list
+.I ACTNAMESPEC
+
+.in +8
+.I ACTSPEC
+:=
+.B action
+.I ACTDETAIL
+[
+.I INDEXSPEC
+] [
+.I COOKIESPEC
+] [
+.I CONTROL
+]
+
+.I ACTISPEC
+:=
+.I ACTNAMESPEC INDEXSPEC
+
+.I ACTNAMESPEC
+:=
+.B action
+ACTNAME
+
+.I INDEXSPEC
+:=
+.BI index " INDEX"
+
+.I COOKIESPEC
+:=
+.BI cookie " COOKIE"
+
+.I ACTDETAIL
+:=
+.I ACTNAME ACTPARAMS
+
+.I ACTNAME
+may be any valid action type: gact, mirred, bpf, connmark, csum, police, etc.
+
+.I ACTPARAMS
+are the action-specific parameters; see the man page for the specific action
+type to be used for details.
+
+.I CONTROL
+:= {
+.IR reclassify " | " pipe " | " drop " | " continue " | " ok
+}
+
+.I TC_OPTIONS
+These are the options that are specific to
+.B tc
+and not only the options. Refer to
+.BR tc(8)
+for more information.
+.in
+
+.SH DESCRIPTION
+
+The
+.B actions
+object in
+.B tc
+allows a user to define actions independently of a classifier (filter). These
+actions can then be assigned to one or more filters, with any
+packets matching the classifier's criteria having that action performed
+on them.
+
+Each action type (mirred, police, etc.) will have its own table to store
+all created actions.
+
+.SH OPERATIONS
+.TP
+.B add
+Create a new action in that action's table.
+
+.TP
+.B change
+.TQ
+.B replace
+Make modifications to an existing action.
+.TP
+.B get
+Display the action with the specified index value. When combined with the
+.B -s
+option for
+.BR tc ","
+display the statistics for that action.
+.TP
+.B delete
+Delete the action with the specified index value. If the action is already
+associated with a classifier, it does not delete the classifier.
+.TP
+.B ls
+.TQ
+.B list
+List all the actions in the specified table. When combined with the
+.B -s
+option for
+.BR tc ","
+display the statistics for all actions in the specified table.
+.TP
+.B flush
+Delete all actions stored in the specified table.
+
+.SH ACTION OPTIONS
+Note that these options are available to all action types.
+.TP
+.BI index " INDEX"
+Specify the table index value of an action.
+.I INDEX
+is a 32-bit value that is unique to the specific type of action referenced.
+
+.RS
+For
+.BR add ", " change ", and"
+.B replace
+operations, the index is
+.BR optional.
+When adding a new action,
+specifying an index value will assign the action to that index unless that
+index value has already been assigned. Omitting the index value for an add
+operation will cause the kernel to assign a value to the new action.
+.RE
+
+.RS
+For
+.BR get " and " delete
+operations, the index is
+.B required
+to identify the specific action to be displayed or deleted.
+.RE
+
+.TP
+.BI cookie " COOKIE"
+In addition to the specific action, mark the matching packet with the value
+specified by
+.IR COOKIE "."
+The
+.I COOKIE
+is a 128-bit value that will not be interpreted by the kernel whatsoever.
+As such, it can be used as a correlating value for maintaining user state.
+The value to be stored is completely arbitrary and does not require a specific
+format. It is stored inside the action structure itself.
+
+.TP
+.I CONTROL
+The
+.I CONTROL
+indicates how
+.B tc
+should proceed after executing the action. Any of the following are valid:
+.RS
+.TP
+.B reclassify
+Restart the classifiction by jumping back to the first filter attached to
+the action's parent.
+.TP
+.B pipe
+Continue with the next action. This is the default control.
+.TP
+.B drop
+Drop the packed without running any further actions.
+.TP
+.B continue
+Continue the classification with the next filter.
+.TP
+.B pass
+Return to the calling qdisc for packet processing, and end classification of
+this packet.
+.RE
+
+.SH SEE ALSO
+.BR tc (8),
+.BR tc-bpf (8),
+.BR tc-connmark (8),
+.BR tc-csum (8),
+.BR tc-ife (8),
+.BR tc-mirred (8),
+.BR tc-nat (8),
+.BR tc-pedit (8),
+.BR tc-police (8),
+.BR tc-simple (8),
+.BR tc-skbedit (8),
+.BR tc-skbmod (8),
+.BR tc-tunnel_key (8),
+.BR tc-vlan (8),
+.BR tc-xt (8)
